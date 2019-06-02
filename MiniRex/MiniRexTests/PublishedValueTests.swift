//
//  PublishedValueTests.swift
//  MiniRexTests
//
//  Created by Óscar Morales Vivó on 6/1/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import XCTest
import MiniRex


class PublishedValueTests: XCTestCase {

    func testSeparateBlocksForInitAndUpdate() {
        let publishedIntProperty = PublishedProperty(withInitialValue: 0)

        let initializationExpecation = expectation(description: "Initialization block called")
        let updateExpectation = expectation(description: "Update block called")

        let subscription = publishedIntProperty.publishedValue.subscribe(initialValueBlock: { (initialValue) in
            initializationExpecation.fulfill()
        }) { (updatedValue) in
            updateExpectation.fulfill()
        }

        publishedIntProperty.value = publishedIntProperty.value + 1

        waitForExpectations(timeout: 1.0)

        subscription.invalidate()
    }
}
