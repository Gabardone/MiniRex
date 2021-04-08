//
//  PublishedValue+BroadcasterTests.swift
//  MiniRexTests
//
//  Created by Óscar Morales Vivó on 6/2/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import XCTest
import MiniRex


class PublishedValue_BroadcasterTests: XCTestCase {

    func testPublishedValueWithBroadcaster() {
        //  We'll filter a published value into a broadcaster to get the right behavior.
        let publishedInt = PublishedProperty<Int>(withInitialValue: -1)

        //  We're filtering out the first update as to erase the first update on subscription from the source.
        var filteredOne = false
        let filterOutExpectation = expectation(description: "Filtered one out")
        let filterInExpectation = expectation(description: "Filtered one in")
        let broadcastFilter = Broadcaster(
            withSource: publishedInt.wrappedValue,
            filterBlock: { (intValue) -> Bool in
                if !filteredOne {
                    filterOutExpectation.fulfill()
                    filteredOne = true
                    return false
                } else {
                    filterInExpectation.fulfill()
                    return true
                }
            }
        )

        let initialValue = 0
        let publishedIntFromBroadcaster = broadcastFilter.publishedValue(withInitialValue: initialValue)

        var receivedValue = -1000
        var updateCount = 0
        let subscriber = publishedIntFromBroadcaster.subscribe { (intValue) in
            receivedValue = intValue
            updateCount += 1
        }

        //  Check that we have received the initial value back (NOT the value that publishedInt was initialized with).
        XCTAssertEqual(receivedValue, initialValue)

        let updatedValue = 7
        publishedInt.value = updatedValue

        //  Check that the update went all the way to our subscriber.
        XCTAssertEqual(receivedValue, updatedValue)

        waitForExpectations(timeout: 1.0)

        subscriber.invalidate()
    }
}
