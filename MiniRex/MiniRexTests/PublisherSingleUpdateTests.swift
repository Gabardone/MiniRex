//
//  PublisherSingleUpdateTests.swift
//  MiniRexTests
//
//  Created by Óscar Morales Vivó on 4/17/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import XCTest
import MiniRex


class PublisherSingleUpdateTests: XCTestCase {

    func testSingleUpdateSubscription() {
        let broadcastInt = 7

        let intBroadcaster = SimpleBroadcaster<Int>()
        let updateExpectation = expectation(description: "SingleUpdate")
        weak var singleUseSubscription = intBroadcaster.broadcaster.subscribeToSingleUpdate { (integer) in
            XCTAssertEqual(integer, broadcastInt)
            updateExpectation.fulfill()
        }

        //  The subscription is still keepint itself alive.
        XCTAssertNotNil(singleUseSubscription)

        intBroadcaster.broadcast(update: broadcastInt)

        waitForExpectations(timeout: 1.0)

        //  Ad this point the subscription should have invalidated and niled itself.
        XCTAssertNil(singleUseSubscription)
    }


    func testSingleUpdatePublishedValueSubscription() {
        let initialValue = 7

        let publishedInteger = PublishedProperty(withInitialValue: initialValue)
        let updateExpectation = expectation(description: "SingleUpdate")
        let singleUseSubscription = publishedInteger.wrappedValue.subscribeToSingleUpdate { (integer) in
            XCTAssertEqual(integer, initialValue)
            updateExpectation.fulfill()
        }

        //  The subscription should have killed itself already since the published property sent its initial update.
        XCTAssertFalse(singleUseSubscription.isSubscribed)

        waitForExpectations(timeout: 1.0)
    }
}
