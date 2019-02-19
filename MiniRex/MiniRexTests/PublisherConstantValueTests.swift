//
//  PublisherConstantValueTests.swift
//  MiniRexTests
//
//  Created by Óscar Morales Vivó on 2/16/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import XCTest
import MiniRex

class PublisherConstantValueTests: XCTestCase {

    func testConstantValuePublisher() {

        var readConstant = 0

        //  Subscribing will involve an immediate callback with the constant value (no dispatching publishers around).
        let subscription = Publisher(withConstant: 7).subscribe({ (update) in
            readConstant = update
        })

        XCTAssertEqual(readConstant, 7)

        subscription.invalidate()
    }
}
