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

        let integerConstant = 7

        let singleUpdatePublisher = Publisher<Int>(withConstant: integerConstant)

        let updateExpectation1 = expectation(description: "Update1")
        let subscription1 = singleUpdatePublisher.subscribe { (integer) in
            XCTAssertEqual(integer, integerConstant)
            updateExpectation1.fulfill()
        }

        subscription1.invalidate()

        let updateExpectation2 = expectation(description: "Update2")
        let subscription2 = singleUpdatePublisher.subscribe { (integer) in
            XCTAssertEqual(integer, integerConstant)
            updateExpectation2.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        subscription2.invalidate()
    }
}
