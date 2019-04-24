//
//  UpdateTransformerTests.swift
//  MiniRexTests
//
//  Created by Óscar Morales Vivó on 2/12/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import XCTest
import MiniRex


class PublisherTransformTests: XCTestCase {

    enum EvenOdd: Equatable {
        case even
        case odd
    }


    func testTransform() {

        let intBroadcaster = SimpleBroadcaster<Int>()
        let evenOddPublisher = intBroadcaster.broadcaster.transform { (integer) -> EvenOdd in
            return (integer % 2) != 0 ? .odd : .even
        }

        var updateCount = 0
        var lastEvenOdd = EvenOdd.even
        let evenOddSubscription = evenOddPublisher.subscribe { (evenOdd) in
            updateCount += 1
            lastEvenOdd = evenOdd
        }

        XCTAssertEqual(updateCount, 0)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastEvenOdd, .even)

        intBroadcaster.broadcast(update: 1)

        XCTAssertEqual(updateCount, 1)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastEvenOdd, .odd)

        intBroadcaster.broadcast(update: 7)

        //  Should be the same as before since the new value is still odd.
        XCTAssertEqual(updateCount, 2)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastEvenOdd, .odd)

        evenOddSubscription.invalidate()
    }


    func testValueTransformerEquatable() {

        let publishedInt = PublishedProperty(withInitialValue: 0)
        let evenOddPublisher = publishedInt.publishedValue.valueTransform { (integer) -> EvenOdd in
            return (integer % 2) != 0 ? .odd : .even
        }

        var updateCount = 0
        var lastEvenOdd = EvenOdd.even
        let evenOddSubscription = evenOddPublisher.subscribe { (evenOdd) in
            updateCount += 1
            lastEvenOdd = evenOdd
        }

        XCTAssertEqual(updateCount, 1)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastEvenOdd, .even)

        publishedInt.value = 1

        XCTAssertEqual(updateCount, 2)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastEvenOdd, .odd)

        publishedInt.value = 7

        //  Should be the same as before since the new value is still odd.
        XCTAssertEqual(updateCount, 2)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastEvenOdd, .odd)

        evenOddSubscription.invalidate()
    }


    func testValueTransformerAnyObject() {

        let testObject1 = NonEquatableTestObject()
        let testObject2 = NonEquatableTestObject()
        let publishedInt = PublishedProperty(withInitialValue: 0)
        let testObjectPublisher = publishedInt.publishedValue.valueTransform { (integer) -> NonEquatableTestObject in
            return (integer % 2) != 0 ? testObject2 : testObject1
        }

        var updateCount = 0
        var lastTestObject = testObject1
        let testObjectSubscription = testObjectPublisher.subscribe { (testObject) in
            updateCount += 1
            lastTestObject = testObject
        }

        XCTAssertEqual(updateCount, 1)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertTrue(lastTestObject === testObject1)

        publishedInt.value = 1

        XCTAssertEqual(updateCount, 2)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertTrue(lastTestObject === testObject2)

        publishedInt.value = 7

        //  Should be the same as before since the new value is still odd.
        XCTAssertEqual(updateCount, 2)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertTrue(lastTestObject === testObject2)

        testObjectSubscription.invalidate()
    }


    func testValueTransformerEquatableAnyObject() {

        let publishedInt = PublishedProperty(withInitialValue: 0)
        let testObjectPublisher = publishedInt.publishedValue.valueTransform { (integer) -> EquatableTestObject in
            return EquatableTestObject(integer % 2)
        }

        var updateCount = 0
        var lastTestObject = EquatableTestObject()
        let testObjectSubscription = testObjectPublisher.subscribe { (testObject) in
            updateCount += 1
            lastTestObject = testObject
        }

        XCTAssertEqual(updateCount, 1)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastTestObject, EquatableTestObject(0))

        publishedInt.value = 1

        XCTAssertEqual(updateCount, 2)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastTestObject, EquatableTestObject(1))

        publishedInt.value = 7

        //  Should be the same as before since the new value is still odd.
        XCTAssertEqual(updateCount, 2)  //  Should have gotten the initial update since there's no async publishers involved.
        XCTAssertEqual(lastTestObject, EquatableTestObject(1))

        testObjectSubscription.invalidate()
    }
}
