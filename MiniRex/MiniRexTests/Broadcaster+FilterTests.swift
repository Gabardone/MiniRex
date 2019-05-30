//
//  Broadcaster+FilterTests.swift
//  MiniRexTests
//
//  Created by Óscar Morales Vivó on 5/30/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import XCTest
import MiniRex


class BroadcasterFilterTests: XCTestCase {

    func testBroadcasterFilter() {
        let sourceBroadcaster = SimpleBroadcaster<Int>()
        let oddFilter = Broadcaster(withSource: sourceBroadcaster.broadcaster, filterBlock: { (integer) -> Bool in
            return (integer % 2) != 0
        })

        var updateCount = 0
        var latestValue: Int? = nil
        let subscription = oddFilter.subscribe { (integer) in
            latestValue = integer
            updateCount += 1
        }

        sourceBroadcaster.broadcast(update: 0)  //  This should be filtered out.

        XCTAssertNil(latestValue)
        XCTAssertEqual(updateCount, 0)

        sourceBroadcaster.broadcast(update: 7)  //  This should go through.

        XCTAssertNotNil(latestValue)
        XCTAssertEqual(latestValue, 7)
        XCTAssertEqual(updateCount, 1)

        subscription.invalidate()
    }
}
