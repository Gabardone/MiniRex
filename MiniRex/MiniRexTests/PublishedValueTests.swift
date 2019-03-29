//
//  PublishedValueTests.swift
//  MiniRexTests
//
//  Created by Óscar Morales Vivó on 2/12/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import XCTest
import MiniRex


class PublishedValueTests: XCTestCase {

    func testPublishedValueEquatable() {
        let publishedInt = PublishedProperty(withInitialValue: 0)

        var updateCount = 0
        var lastInteger = 0
        let intSubscription = publishedInt.publisher.subscribe { (integer) in
            updateCount += 1
            lastInteger = integer
        }

        XCTAssertEqual(updateCount, 1)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastInteger, 0)

        publishedInt.value = 7

        XCTAssertEqual(updateCount, 2)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastInteger, 7)

        publishedInt.value = 7

        //  Should be the same as before since the new value was the same.
        XCTAssertEqual(updateCount, 2)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastInteger, 7)

        intSubscription.invalidate()
    }


    func testValueTransformerAnyObject() {
        let testObject1 = NonEquatableTestObject(0)
        let testObject2 = NonEquatableTestObject(1)
        let publishedTestObject = PublishedProperty(withInitialValue: testObject1)

        var updateCount = 0
        var lastTestObject = testObject1
        let testObjectSubscription = publishedTestObject.publisher.subscribe { (testObject) in
            updateCount += 1
            lastTestObject = testObject
        }

        XCTAssertEqual(updateCount, 1)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertTrue(lastTestObject === testObject1)

        publishedTestObject.value = testObject2

        XCTAssertEqual(updateCount, 2)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertTrue(lastTestObject === testObject2)

        publishedTestObject.value = testObject2

        //  Should be the same as before since the new value is still odd.
        XCTAssertEqual(updateCount, 2)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertTrue(lastTestObject === testObject2)

        testObjectSubscription.invalidate()
    }


    func testValueTransformerEquatableAnyObject() {
        let testObject1 = EquatableTestObject(0)
        let testObject2 = EquatableTestObject(1)
        let publishedTestObject = PublishedProperty(withInitialValue: testObject1)

        var updateCount = 0
        var lastTestObject = testObject1
        let testObjectSubscription = publishedTestObject.publisher.subscribe { (testObject) in
            updateCount += 1
            lastTestObject = testObject
        }

        XCTAssertEqual(updateCount, 1)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastTestObject, EquatableTestObject(0))

        publishedTestObject.value = testObject2

        XCTAssertEqual(updateCount, 2)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastTestObject, EquatableTestObject(1))

        publishedTestObject.value = EquatableTestObject(1)

        //  Should be the same as before since the new value is still odd.
        XCTAssertEqual(updateCount, 2)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastTestObject, EquatableTestObject(1))

        testObjectSubscription.invalidate()
    }
}
