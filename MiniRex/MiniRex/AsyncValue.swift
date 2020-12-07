//
//  AsyncValue.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 12/6/20.
//  Copyright © 2020 Óscar Morales Vivó. All rights reserved.
//

import Foundation


/**
 Encapsulates a value such that it can be both accessed and set, but only asynchronously.

 In a better world this would be a protocol but then Swift starts getting in the way because of all its limitations
 related to generic protocls so building this simple type on the fly when needed will do.
 */
public struct AsyncValue<T> {

    /// We inject a block to set the value when initalizing an instance.
    private let setter: (T) -> Void

    /// Access to the value only happens through a publisher.
    public let value: Published<T>

    /**
     Call this method to set the value to the given one. This API is not meant to deal with errors when setting the
     value but any updates to the actual value will be published through `value`.
     - Parameter value: The value we'd like the async value to be set to.
     */
    public func set(to value: T) {
        setter(value)
    }

    /**
     Public Initializer. Does what you expect.
     */
    public init(publishedValue: Published<T>, setter: @escaping (T) -> Void) {
        self.setter = setter
        self.value = publishedValue
    }
}
