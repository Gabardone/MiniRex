//
//  KVOPublisherTests.swift
//  MiniRexTests
//
//  Created by Oscar Morales Vivo on 11/11/18.
//  Copyright © 2018 Óscar Morales Vivó. All rights reserved.
//

import XCTest
@testable import MiniRex


class TestNSObject: NSObject {

    @objc dynamic var integer: Int = 7

    deinit {
        print("I'm going awaaaaay")
    }
}


class KVOPublisherTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func testLifeCycle() {
        var instance: TestNSObject? = TestNSObject()

        var observer: NSKeyValueObservation? = instance?.observe(\TestNSObject.integer, options: [.new], changeHandler: { (instance, change) in
            print("I have chaaaanged to value \(change.newValue!)")
        })

        instance?.integer = 77

        instance = nil

        observer = nil
    }




//    func testInitialization() {
//        let testObject = TestNSObject()
//        var initializationRunCount: Int = 0
//        var initialValue: Int = 0
//        let initializationBlock = { (value: Int) in
//            initialValue = value
//            initializationRunCount += 1
//        }
//        let updateBlock = { (value: Int) in
//            //  It's a nop.
//        }
//
//        testObject.subscribe(\.integer, initializationBlock: initializationBlock, updateBlock: updateBlock)
//
//        XCTAssertEqual(initialValue, 7)
//    }
}
