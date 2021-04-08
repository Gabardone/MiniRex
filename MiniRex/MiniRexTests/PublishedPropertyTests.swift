//
//  PublishedPropertyTests.swift
//  MiniRexTests
//
//  Created by Óscar Morales Vivó on 2/12/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import XCTest
import MiniRex


class PublishedPropertyTests: XCTestCase {

    func testPublishedPropertyEquatable() {
        let publishedInt = PublishedProperty(withInitialValue: 0)

        var updateCount = 0
        var lastInteger = 0
        let intSubscription = publishedInt.wrappedValue.subscribe { (integer) in
            updateCount += 1
            lastInteger = integer
        }

        XCTAssertEqual(updateCount, 1)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastInteger, 0)

        publishedInt.value = 7

        XCTAssertEqual(publishedInt.value, 7)
        XCTAssertEqual(updateCount, 2)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastInteger, 7)

        publishedInt.value = 7

        //  Should be the same as before since the new value was the same.
        XCTAssertEqual(updateCount, 2)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastInteger, 7)

        intSubscription.invalidate()
    }


    func testPublishedPropertyEquatableWrapper() {
        struct TestStruct {
            @PublishedProperty var publishedInt: MiniRex.Published<Int>

            var value: Int {
                get {
                    return _publishedInt.value
                }

                set {
                    _publishedInt.value = newValue
                }
            }

            init(intValue: Int) {
                self._publishedInt = PublishedProperty(withInitialValue: intValue)
            }
        }
        var testStruct = TestStruct(intValue: 0)

        var updateCount = 0
        var lastInteger = 0
        let intSubscription = testStruct.publishedInt.subscribe { (integer) in
            updateCount += 1
            lastInteger = integer
        }

        XCTAssertEqual(updateCount, 1)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastInteger, 0)

        testStruct.value = 7

        XCTAssertEqual(testStruct.value, 7)
        XCTAssertEqual(updateCount, 2)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastInteger, 7)

        testStruct.value = 7

        //  Should be the same as before since the new value was the same.
        XCTAssertEqual(updateCount, 2)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastInteger, 7)

        intSubscription.invalidate()
    }


    func testPublishedPropertyAnyObject() {
        let testObject1 = NonEquatableTestObject(0)
        let testObject2 = NonEquatableTestObject(1)
        let publishedTestObject = PublishedProperty(withInitialValue: testObject1)

        var updateCount = 0
        var lastTestObject = testObject1
        let testObjectSubscription = publishedTestObject.wrappedValue.subscribe { (testObject) in
            updateCount += 1
            lastTestObject = testObject
        }

        XCTAssertEqual(updateCount, 1)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertTrue(lastTestObject === testObject1)

        publishedTestObject.value = testObject2

        XCTAssert(publishedTestObject.value === testObject2)
        XCTAssertEqual(updateCount, 2)  //  Different object, another update.
        XCTAssertTrue(lastTestObject === testObject2)

        publishedTestObject.value = testObject2

        //  Should be the same as before since the new value is still odd.
        XCTAssertEqual(updateCount, 2)  //  Same object updated, no update received.
        XCTAssertTrue(lastTestObject === testObject2)

        testObjectSubscription.invalidate()
    }


    func testPublishedPropertyEquatableAnyObject() {
        let testObject1 = EquatableTestObject(0)
        let testObject2 = EquatableTestObject(1)
        let publishedTestObject = PublishedProperty(withInitialValue: testObject1)

        var updateCount = 0
        var lastTestObject = testObject1
        let testObjectSubscription = publishedTestObject.wrappedValue.subscribe { (testObject) in
            updateCount += 1
            lastTestObject = testObject
        }

        XCTAssertEqual(updateCount, 1)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastTestObject, EquatableTestObject(0))

        publishedTestObject.value = testObject2

        XCTAssertEqual(publishedTestObject.value, testObject2)
        XCTAssertEqual(updateCount, 2)  //  Different object, new update.
        XCTAssertEqual(lastTestObject, EquatableTestObject(1))

        publishedTestObject.value = EquatableTestObject(1)

        //  Should be the same as before since the new value is still odd.
        XCTAssertEqual(updateCount, 2)  //  Different object but same value per Equatable, no update.
        XCTAssertEqual(lastTestObject, EquatableTestObject(1))

        testObjectSubscription.invalidate()
    }


    func testPublishedPropertyNonEquatableNonObject() {
        let publishedNonEquatableNonObject = PublishedProperty(withInitialValue: NonEquatableNonObject(intValue: 0))

        var updateCount = 0
        var lastValue = NonEquatableNonObject(intValue: -1)
        let subscription = publishedNonEquatableNonObject.wrappedValue.subscribe { (value) in
            updateCount += 1
            lastValue = value
        }

        XCTAssertEqual(updateCount, 1)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastValue.intValue, 0)

        publishedNonEquatableNonObject.value = NonEquatableNonObject(intValue: 7)

        XCTAssertEqual(publishedNonEquatableNonObject.value.intValue, 7)
        XCTAssertEqual(updateCount, 2)  //  New update with the given struct.
        XCTAssertEqual(lastValue.intValue, 7)

        publishedNonEquatableNonObject.value = NonEquatableNonObject(intValue: 7)

        //  Should be the same as before since the new value was the same.
        XCTAssertEqual(updateCount, 3)  //  While the struct looks the same since it's not equatable, another update happened.
        XCTAssertEqual(lastValue.intValue, 7)

        subscription.invalidate()
    }
}
