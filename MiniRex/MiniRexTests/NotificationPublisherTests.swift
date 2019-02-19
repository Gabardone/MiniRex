//
//  NotificationPublisherTests.swift
//  MiniRexTests
//
//  Created by Óscar Morales Vivó on 2/16/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import XCTest
import MiniRex


class NotificationPublisherTests: XCTestCase {

    static let testNotificationName = Notification.Name("MiniRexTestNotification")

    func testNotificationPublisher() {

        let notificationCenter = NotificationCenter.default
        var updateBlockCallCount = 0

        //  System is smart enough to call notification observer blocks synchronously if the notification is posted on
        //  the same queue as specified for the block.
        let subscription = notificationCenter.subscribe(forName: NotificationPublisherTests.testNotificationName, object: nil, queue: OperationQueue.main) { (notification) in
            updateBlockCallCount += 1
        }

        //  Sanity check, subscribing does nothing (this is not a value publisher).
        XCTAssertEqual(updateBlockCallCount, 0)

        //  Post a notification of the required type and see what's up.
        notificationCenter.post(name: NotificationPublisherTests.testNotificationName, object: nil)
        XCTAssertEqual(updateBlockCallCount, 1)

        subscription.invalidate()

        //  Test that unsubscribing worked out.
        notificationCenter.post(name: NotificationPublisherTests.testNotificationName, object: nil)
        XCTAssertEqual(updateBlockCallCount, 1)
    }
}
