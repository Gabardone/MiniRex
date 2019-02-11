//
//  KVOPublisherTests.swift
//  MiniRexTests
//
//  Created by Oscar Morales Vivo on 11/11/18.
//  Copyright © 2018 Óscar Morales Vivó. All rights reserved.
//

import XCTest
@testable import MiniRex


class TestNSObject: NSObject {

    static let initialValue = 7

    @objc dynamic var integer: Int = initialValue

    @objc dynamic var array: [Int] = [initialValue]

    deinit {
        print("I'm going awaaaaay")
    }
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
        let publisher = self.testObject.publisher(forKeyPath: \TestNSObject.integer, keyValueObservingOptions: [.initial, .new])

        var hasReceivedInitialKVOCall = false

        let _ = publisher.subscribe { (update: (object: TestNSObject, change: NSKeyValueObservedChange<Int>)) in
            XCTAssertEqual(self.testObject!, update.object)
            XCTAssertEqual(update.change.kind, NSKeyValueChange.setting)
            XCTAssertEqual(update.change.newValue, TestNSObject.initialValue)
            XCTAssertNil(update.change.oldValue)
            XCTAssertFalse(update.change.isPrior)

            hasReceivedInitialKVOCall = true
        }

        XCTAssertTrue(hasReceivedInitialKVOCall, "Initial KVO call not received by update block.")
    }


    func testSwiftKeyPathPublisherUpdates() {
        let newValue = TestNSObject.initialValue * 11
        let publisher = self.testObject.publisher(forKeyPath: \TestNSObject.integer, keyValueObservingOptions: [.new, .old])

        var hasReceivedUpdateKVOCall = false

        let subscription = publisher.subscribe { (update: (object: TestNSObject, change: NSKeyValueObservedChange<Int>)) in
            XCTAssertEqual(self.testObject!, update.object)
            XCTAssertEqual(update.change.kind, NSKeyValueChange.setting)
            XCTAssertEqual(update.change.oldValue, TestNSObject.initialValue)
            XCTAssertEqual(update.change.newValue, newValue)
            XCTAssertFalse(update.change.isPrior)

            hasReceivedUpdateKVOCall = true
        }

        self.testObject.integer = newValue

        subscription.invalidate()   //  Mostly so the compiler doesn't complain about subscription not being changed.

        XCTAssertTrue(hasReceivedUpdateKVOCall, "Update KVO call not received by update block.")
    }


    func testStringKeyPathPublisherAdvanced() {
        let newValue = [7, 77, 777]
        let publisher = self.testObject.publisher(forKeyPathString: "array.@count", keyValueObservingOptions: [.new, .old])

        var hasReceivedUpdateKVOCall = false

        let subscription = publisher.subscribe { (update: (object: Any?, change: [NSKeyValueChangeKey : Any]?)) in
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

            hasReceivedUpdateKVOCall = true
        }

        self.testObject.array = newValue

        subscription.invalidate()   //  Mostly so the compiler doesn't complain about subscription not being changed.

        XCTAssertTrue(hasReceivedUpdateKVOCall, "Update KVO call not received by update block.")
    }
}
