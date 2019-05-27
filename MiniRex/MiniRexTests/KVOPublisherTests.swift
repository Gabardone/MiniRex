//
//  KVOPublisherTests.swift
//  MiniRexTests
//
//  Created by Oscar Morales Vivo on 11/11/18.
//  Copyright © 2018 Óscar Morales Vivó. All rights reserved.
//

import XCTest
import MiniRex


class TestNSObject: NSObject {

    static let initialValue = 7

    @objc dynamic var integer: Int = initialValue

    @objc dynamic var array: [Int] = [initialValue]

    @objc dynamic var optional: NSNumber? = nil
}


class KVOPublisherTests: XCTestCase {

    var testObject: TestNSObject!

    override func setUp() {
        super.setUp()

        testObject = TestNSObject()
    }
    
    override func tearDown() {
        testObject = nil

        super.tearDown()
    }


    func testSwiftKeyPathPublisherInitial() {
        var receivedKVOCalls = 0

        let subscription = self.testObject.subscribe(toKeyPath: \TestNSObject.integer, keyValueObservingOptions: [.initial, .new]) { (update: (object: TestNSObject, change: NSKeyValueObservedChange<Int>)) in
            XCTAssertEqual(self.testObject!, update.object)
            XCTAssertEqual(update.change.kind, NSKeyValueChange.setting)
            XCTAssertEqual(update.change.newValue, TestNSObject.initialValue)
            XCTAssertNil(update.change.oldValue)
            XCTAssertFalse(update.change.isPrior)

            receivedKVOCalls += 1
        }

        XCTAssertEqual(receivedKVOCalls, 1)

        //  Test that no further updates are received after unsubscribing.
        subscription.invalidate()
        self.testObject.integer = 0
        XCTAssertEqual(receivedKVOCalls, 1)
    }


    func testSwiftKeyPathPublisherUpdates() {
        let newValue = TestNSObject.initialValue * 11
        var receivedKVOCalls = 0

        let subscription = self.testObject.subscribe(toKeyPath: \TestNSObject.integer, keyValueObservingOptions: [.new, .old]) { (update: (object: TestNSObject, change: NSKeyValueObservedChange<Int>)) in
            XCTAssertEqual(self.testObject!, update.object)
            XCTAssertEqual(update.change.kind, NSKeyValueChange.setting)
            XCTAssertEqual(update.change.oldValue, TestNSObject.initialValue)
            XCTAssertEqual(update.change.newValue, newValue)
            XCTAssertFalse(update.change.isPrior)

            receivedKVOCalls += 1
        }

        self.testObject.integer = newValue

        XCTAssertEqual(receivedKVOCalls, 1)

        //  Test that no further updates are received after unsubscribing.
        subscription.invalidate()
        self.testObject.integer = 0
        XCTAssertEqual(receivedKVOCalls, 1)
    }


    func testSwiftKeyPathSimpleAPI() {
        let newValue = TestNSObject.initialValue * 11
        let publisher = self.testObject.publishedValue(forKeyPathUpdates: \TestNSObject.integer)

        var receivedValues: [Int] = []

        let subscription = publisher.subscribe { (update: Int) in
            receivedValues.append(update)
        }

        //  At this point we should only have gotten the initial update call.
        XCTAssertEqual(receivedValues, [TestNSObject.initialValue])

        self.testObject.integer = newValue

        XCTAssertEqual(receivedValues, [TestNSObject.initialValue, newValue])

        //  See that unsubscribing works. Make sure no further updates are received after invalidating the subscriber.
        subscription.invalidate()
        self.testObject.integer = 0
        XCTAssertEqual(receivedValues, [TestNSObject.initialValue, newValue])
    }


    func testStringKeyPathPublisherAdvanced() {
        let newValue = [7, 77, 777]

        var receivedUpdateCount = 0

        let subscription = self.testObject.subscribe(toKeyPathString: "array.@count", keyValueObservingOptions: [.new, .old]) { (update: (object: Any?, change: [NSKeyValueChangeKey : Any]?)) in
            guard let object = update.object else {
                XCTAssertNotNil(update.object)
                return
            }
            guard let change = update.change else {
                XCTAssertNotNil(update.change)
                return
            }

            //  The old KVO API sure is unwieldy in Swift.
            XCTAssertEqual(self.testObject, object as? TestNSObject)
            XCTAssertEqual(change[.kindKey] as? UInt, NSKeyValueChange.setting.rawValue)
            XCTAssertEqual(change[.oldKey] as! Int, 1)
            XCTAssertEqual(change[.newKey] as! Int, 3)
            XCTAssertFalse((change[.notificationIsPriorKey] as? Bool) ?? false)

            receivedUpdateCount += 1
        }

        self.testObject.array = newValue
        XCTAssertEqual(receivedUpdateCount, 1)

        //  Test that unsubscribing works.
        subscription.invalidate()
        self.testObject.array = []
        XCTAssertEqual(receivedUpdateCount, 1)
    }


    func testStringKeyPathPublisherSimpleAPI() {
        let newValue = [7, 77, 777]

        var receivedUpdates: [Int] = []

        let subscription = self.testObject.subscribe(toValueAtKeyPathString: "array") { (update: [Int]) in
            receivedUpdates.append(contentsOf: update)
        }

        //  Should have received the initial update.
        XCTAssertEqual(receivedUpdates, [TestNSObject.initialValue])

        //  Update.
        testObject.array = newValue

        XCTAssertEqual(receivedUpdates, [TestNSObject.initialValue] + newValue)

        //  Test that unsubscribing works.
        subscription.invalidate()
        self.testObject.array = []
        XCTAssertEqual(receivedUpdates, [TestNSObject.initialValue] + newValue)
    }


    func testStringKeyPathOptional() {
        var receivedUpdates: [NSNumber?] = []

        let publisher: Published<NSNumber?> = self.testObject.publishedValue(forKeyPathString: "optional")
        let subscription = publisher.subscribe { (update: NSNumber?) in
            receivedUpdates.append(update)
        }

        //  Should have received the initial update.
        XCTAssertEqual(receivedUpdates, [nil])

        //  Update.
        testObject.optional = NSNumber(booleanLiteral: true)

        XCTAssertEqual(receivedUpdates, [nil, NSNumber(booleanLiteral: true)])

        //  Test that unsubscribing works.
        subscription.invalidate()
        self.testObject.optional = NSNumber(integerLiteral: 7)
        XCTAssertEqual(receivedUpdates, [nil, NSNumber(booleanLiteral: true)])
    }


    func testSafeDeallocationOfKeyPathSubscription() {
        var testObject: TestNSObject? = TestNSObject()

        let kvoPublisher = testObject!.broadcaster(forKeyPath: \TestNSObject.integer, keyValueObservingOptions: [.new, .initial])

        testObject = nil

        let subscription = kvoPublisher.subscribe { (_, _) in
            XCTFail("The subscription update block should never be called in this test")
        }

        XCTAssertFalse(subscription.isSubscribed)
    }


    func testSafeDeallocationOfKeyPathStringSubscription() {
        var testObject: TestNSObject? = TestNSObject()

        let kvoPublisher = testObject!.broadcaster(forKeyPathString: "array.@count", keyValueObservingOptions: [.new])

        testObject = nil

        let subscription = kvoPublisher.subscribe { (_, _) in
            XCTFail("The subscription update block should never be called in this test")
        }

        XCTAssertFalse(subscription.isSubscribed)
    }
}
