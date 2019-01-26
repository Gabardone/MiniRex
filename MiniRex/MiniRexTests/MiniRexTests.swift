//
//  MiniRexTests.swift
//  MiniRexTests
//
//  Created by Óscar Morales Vivó on 10/28/18.
//  Copyright © 2018 Óscar Morales Vivó. All rights reserved.
//

import XCTest
@testable import MiniRex

class TestClass {

    deinit {
        print("I'm going away...")
    }
}

class MiniRexTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {

        var strongReference: TestClass? = TestClass()
        weak var weakReference: TestClass? = strongReference


        strongReference = nil
        print("This is my weakness: \(String(describing: weakReference))")
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}
