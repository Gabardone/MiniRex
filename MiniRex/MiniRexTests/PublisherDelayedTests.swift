//
//  PublisherDelayedTests.swift
//  MiniRexTests
//
//  Created by Óscar Morales Vivó on 10/20/20.
//  Copyright © 2020 Óscar Morales Vivó. All rights reserved.
//

import XCTest
import MiniRex

class PublisherDelayedTests: XCTestCase {

    func testSubscribeDelayedUnsubscribeBeforeUpdates() {
        //  Basic publisher does nothing but fail since we're expecting that actual subscription won't happen.
        let publisher = MiniRex.Published<Int>(withSubscribeBlock: { (updateBlock) -> Subscription in
            XCTFail("We shouldn't hit inner subscription in this test.")
            return Subscription(withUnsubscriber: {})
        })

        //  Build the adapter that will dispatch subscription logic into our test queue half a second later.
        let dispatchedPublisher = publisher.dispatch(after: .milliseconds(500))

        //  Finally subscribe so we run all of the above.
        let subscription = dispatchedPublisher.subscribe { (integer) in
            XCTFail("We shouldn't hit an actual update in this test")
        }

        //  Sleep for a much shorter time than the subscription delay.
        Thread.sleep(forTimeInterval: 0.1)

        subscription.invalidate()
    }


    /**
     Same as PublishedDispatchTest.testSubscribeDispatch but adding a delay to the subscription smaller than the
     time we wait for fulfilled expectations.
     */
    func testSubscribeDelayed() {
        //  Expectation run when we subscribe like a semaphore.
        let subscribeExpectation = expectation(description: "Subscription")

        //  Basic publisher does nothing but run our testing logic and return an empty Subscription.
        let publisher = MiniRex.Published<Int>(withSubscribeBlock: { (updateBlock) -> Subscription in
            subscribeExpectation.fulfill()
            return Subscription(withUnsubscriber: {})
        })

        //  Build the adapter that will dispatch subscription logic into our test queue.
        let dispatchedPublisher = publisher.dispatch(after: .milliseconds(100))

        //  Finally subscribe so we run all of the above.
        let subscription = dispatchedPublisher.subscribe { (integer) in
        }

        //  The timeout means the test will technically fail if we stop in the debugger while waiting.
        waitForExpectations(timeout: 1.0)

        subscription.invalidate()
    }
}
