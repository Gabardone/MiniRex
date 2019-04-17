//
//  PublisherDispatchTests.swift
//  MiniRexTests
//
//  Created by Óscar Morales Vivó on 3/28/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import XCTest
import MiniRex

class PublisherDispatchTests: XCTestCase {

    func testSubscribeDispatch() {

        //  We use the getSpecific/setSpecific Dispatch API to associate data to our test queue and verify that we're
        //  executing in it (the assert methods blow up which is not what we want for tests).
        let subscribeQueue = DispatchQueue(label: "SubscribeTestQueue")
        let key = DispatchSpecificKey<Int>()
        subscribeQueue.setSpecific(key: key, value: 7)

        //  Expectation run when we subscribe like a semaphore.
        let subscribeExpectation = expectation(description: "Subscription")

        //  Basic publisher does nothing but run our testing logic and return an empty Subscription.
        let publisher = Publisher<Int>(withSubscribeBlock: { (updateBlock) -> Subscription in
            let specificValue = DispatchQueue.getSpecific(key: key)
            XCTAssertNotNil(specificValue)
            if let specificInt = specificValue {
                XCTAssertEqual(specificInt, 7)
            }
            subscribeExpectation.fulfill()
            return Subscription(withUnsubscriber: {})
        })

        //  Build the adapter that will dispatch subscription logic into our test queue.
        let dispatchedPublisher = publisher.dispatch(subscribeQueue: subscribeQueue)

        //  Finally subscribe so we run all of the above.
        let subscription = dispatchedPublisher.subscribe { (integer) in
        }

        //  The timeout means the test will technically fail if we stop in the debugger while waiting.
        waitForExpectations(timeout: 1.0, handler: nil)

        subscription.invalidate()
    }
}
