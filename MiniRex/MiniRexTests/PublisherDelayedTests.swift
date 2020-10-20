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

        //  We use the getSpecific/setSpecific Dispatch API to associate data to our test queue and verify that we're
        //  executing in it (the assert methods blow up which is not what we want for tests).
        let subscribeQueueLabel = "UpdateTestQueue"
        let subscribeQueue = DispatchQueue(label: subscribeQueueLabel)
        let key = DispatchSpecificKey<String>()
        subscribeQueue.setSpecific(key: key, value: subscribeQueueLabel)

        //  Basic publisher does nothing but fail since we're expecting that actual subscription won't happen.
        let publisher = MiniRex.Published<Int>(withSubscribeBlock: { (updateBlock) -> Subscription in
            XCTFail("We shouldn't hit inner subscription in this test.")
            return Subscription(withUnsubscriber: {})
        })

        //  Build the adapter that will dispatch subscription logic into our test queue half a second later.
        let dispatchedPublisher = publisher.dispatch(after: .milliseconds(500), subscribeQueue: subscribeQueue)

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

        //  We use the getSpecific/setSpecific Dispatch API to associate data to our test queue and verify that we're
        //  executing in it (the assert methods blow up which is not what we want for tests).
        let subscribeQueueLabel = "UpdateTestQueue"
        let subscribeQueue = DispatchQueue(label: subscribeQueueLabel)
        let key = DispatchSpecificKey<String>()
        subscribeQueue.setSpecific(key: key, value: subscribeQueueLabel)

        //  Expectation run when we subscribe like a semaphore.
        let subscribeExpectation = expectation(description: "Subscription")

        //  Basic publisher does nothing but run our testing logic and return an empty Subscription.
        let publisher = MiniRex.Published<Int>(withSubscribeBlock: { (updateBlock) -> Subscription in
            let specificValue = DispatchQueue.getSpecific(key: key)
            XCTAssertNotNil(specificValue)
            if let specificString = specificValue {
                XCTAssertEqual(specificString, subscribeQueueLabel)
            }
            subscribeExpectation.fulfill()
            return Subscription(withUnsubscriber: {})
        })

        //  Build the adapter that will dispatch subscription logic into our test queue.
        let dispatchedPublisher = publisher.dispatch(after: .milliseconds(100), subscribeQueue: subscribeQueue)

        //  Finally subscribe so we run all of the above.
        let subscription = dispatchedPublisher.subscribe { (integer) in
        }

        //  The timeout means the test will technically fail if we stop in the debugger while waiting.
        waitForExpectations(timeout: 1.0)

        subscription.invalidate()
    }
}
