//
//  SimpleBroadcasterTests.swift
//  MiniRexTests
//
//  Created by Óscar Morales Vivó on 4/17/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import XCTest
import MiniRex


class SimpleBroadcasterTests: XCTestCase {

    func testSimpleBroadcasterSubscription() {
        let broadcastValue = 7

        let simpleBroadcaster = SimpleBroadcaster<Int>()

        let updateExpectation = expectation(description: "Update")
        let subscription = simpleBroadcaster.broadcaster.subscribe { (integer) in
            XCTAssertEqual(integer, broadcastValue)
            updateExpectation.fulfill()
        }

        //  Do the actual broadcasting.
        simpleBroadcaster.broadcast(update: broadcastValue)

        //  And make sure the update got called.
        waitForExpectations(timeout: 1.0, handler: nil)

        subscription.invalidate()
    }


    func testSimpleBroadcasterOrderlyDeallocation() {
        var simpleBroadcaster: SimpleBroadcaster<Int>? = SimpleBroadcaster<Int>()
        let asyncPublisher = simpleBroadcaster?.broadcaster
        simpleBroadcaster = nil

        XCTAssertNotNil(asyncPublisher)

        guard let publisher = asyncPublisher else {
            //  We would already have failed the assert so no need to do anything here.
            return
        }

        let subscription = publisher.subscribe({_ in })

        XCTAssertFalse(subscription.isSubscribed)
    }
}
