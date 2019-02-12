//
//  UpdateTransformerTests.swift
//  MiniRexTests
//
//  Created by Óscar Morales Vivó on 2/12/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import XCTest
@testable import MiniRex


class UpdateTransformerTests: XCTestCase {

    func testValueTransformer() {

        enum EvenOdd: Equatable {
            case even
            case odd
        }

        let publishedInt = PublishedValue(withInitialValue: 0)
        let evenOddPublisher = publishedInt.publisher.valueTransform { (integer) -> EvenOdd in
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
}
