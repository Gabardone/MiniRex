//
//  TestTypes.swift
//  MiniRexTests
//
//  Created by Óscar Morales Vivó on 2/12/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation



class NonEquatableTestObject {

    var intValue = 0

    init(_ intValue: Int = 0) {
        self.intValue = intValue
    }
}


class EquatableTestObject: Equatable {

    static func == (lhs: EquatableTestObject, rhs: EquatableTestObject) -> Bool {
        return lhs.intValue == rhs.intValue
    }

    var intValue = 0

    init(_ intValue: Int = 0) {
        self.intValue = intValue
    }
}
