//
//  PublishedValue+Transform.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 5/13/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


extension Published {

    /**
     Builds a Publisher that transform another publisher's updates. It will only update subscribers if the new value
     should update subscribers, by checking for equality or, failing that, identity.

     If applied to a PublishedValue, will act as another PublishedValue as it will obtain an initial value as soon as
     any subscription happens.
     - Parameter sourcePublisher: The publisher whose updates are the source for the one we're building.
     - Parameter valueTransformationBlock: A block that converts a source update into one of the kind we want for the
     publisher we're creating.

     The transformationBlock can transform into any type whatsoever, including the source's type, so there is no
     limitation about it other than it has to produce a value for every source update.
     */
    init<OriginalValue>(withSource sourcePublisher: Published<OriginalValue>, valueTransformationBlock: @escaping (OriginalValue) -> Update) {
        self.init(withSubscribeBlock: { (updateBlock: @escaping (Update) -> Void) in
            return sourcePublisher.subscribe({ (update) in
                updateBlock(valueTransformationBlock(update))
            })
        })
    }
}


extension Published where Update: Equatable {

    /**
     Builds a Publisher that transform another publisher's updates. It will only update subscribers if the new value
     should update subscribers, by checking for equality or, failing that, identity.

     If applied to a PublishedValue, will act as another PublishedValue as it will obtain an initial value as soon as
     any subscription happens.
     - Parameter sourcePublisher: The publisher whose updates are the source for the one we're building.
     - Parameter valueTransformationBlock: A block that converts a source update into one of the kind we want for the
     publisher we're creating.

     The transformationBlock can transform into any type whatsoever, including the source's type, so there is no
     limitation about it other than it has to produce a value for every source update.
     */
    init<OriginalValue>(withSource sourcePublisher: Published<OriginalValue>, valueTransformationBlock: @escaping (OriginalValue) -> Update) {
        self.init(withSubscribeBlock: { (updateBlock: @escaping (Update) -> Void) in
            var initialized = false //  We need the flag in case Update is an optional.
            var cachedValue: Update?
            return sourcePublisher.subscribe({ (update) in
                let newValue = valueTransformationBlock(update)
                if !initialized || cachedValue! != newValue {
                    initialized = true
                    cachedValue = newValue
                    updateBlock(newValue)
                }
            })
        })
    }
}


extension Published where Update: AnyObject {

    /**
     Builds a Publisher that transform another publisher's updates. It will only update subscribers if the new value
     should update subscribers, by checking for equality or, failing that, identity.

     If applied to a PublishedValue, will act as another PublishedValue as it will obtain an initial value as soon as
     any subscription happens.
     - Parameter sourcePublisher: The publisher whose updates are the source for the one we're building.
     - Parameter valueTransformationBlock: A block that converts a source update into one of the kind we want for the
     publisher we're creating.

     The transformationBlock can transform into any type whatsoever, including the source's type, so there is no
     limitation about it other than it has to produce a value for every source update.
     */
    init<OriginalValue>(withSource sourcePublisher: Published<OriginalValue>, valueTransformationBlock: @escaping (OriginalValue) -> Update) {
        self.init(withSubscribeBlock: { (updateBlock: @escaping (Update) -> Void) in
            var initialized = false //  We need the flag in case Update is an optional.
            var cachedValue: Update?
            return sourcePublisher.subscribe({ (update) in
                let newValue = valueTransformationBlock(update)
                if !initialized || cachedValue! !== newValue {
                    initialized = true
                    cachedValue = newValue
                    updateBlock(newValue)
                }
            })
        })
    }
}


extension Published where Update: AnyObject & Equatable {

    /**
     Builds a Publisher that transform another publisher's updates. It will only update subscribers if the new value
     should update subscribers, by checking for equality or, failing that, identity.

     If applied to a PublishedValue, will act as another PublishedValue as it will obtain an initial value as soon as
     any subscription happens.
     - Parameter sourcePublisher: The publisher whose updates are the source for the one we're building.
     - Parameter valueTransformationBlock: A block that converts a source update into one of the kind we want for the
     publisher we're creating.

     The transformationBlock can transform into any type whatsoever, including the source's type, so there is no
     limitation about it other than it has to produce a value for every source update.
     */
    init<OriginalValue>(withSource sourcePublisher: Published<OriginalValue>, valueTransformationBlock: @escaping (OriginalValue) -> Update) {
        self.init(withSubscribeBlock: { (updateBlock: @escaping (Update) -> Void) in
            var initialized = false //  We need the flag in case Update is an optional.
            var cachedValue: Update?
            return sourcePublisher.subscribe({ (update) in
                let newValue = valueTransformationBlock(update)
                if !initialized || cachedValue! != newValue {
                    initialized = true
                    cachedValue = newValue
                    updateBlock(newValue)
                }
            })
        })
    }
}


extension Published {
    
    /**
     Builds up a publisher that transforms the value updates from the caller into new values.

     Unlike the regular transform Publisher that always updates publishers when it gets an update itself, this one will
     only update subscribers if the updated, transformed value is different than the last transformed value, complying
     with the expected semantics of a published value.

     - Note: If used with a reference type, a Subscription to this publisher will keep a strong reference to the last
     transformed value. In some odd cases where the transformed objects are being retrieved from a pool of objects as
     opposed to being created on the fly whenever valueTransformationBlock is called this could lead to a retain cycle.
     - Parameter transformationBlock: A block that converts the caller's updates into ones of the kind we want for the
     publisher we're creating.
     - Returns: A publisher whose subscribers will get the same updates as the caller, but transformed by the given
     block.

     The transformationBlock can transform into any type whatsoever, including the source's type, so there is no
     limitation about it other than it has to produce a value for every source update.
     */
    public func valueTransform<Transformed>(with valueTransformationBlock: @escaping (Update) -> Transformed) -> Published<Transformed> {
        return Published<Transformed>(withSource: self, valueTransformationBlock: valueTransformationBlock)
    }


    public func valueTransform<Transformed>(with valueTransformationBlock: @escaping (Update) -> Transformed) -> Published<Transformed> where Transformed: Equatable {
        return Published<Transformed>(withSource: self, valueTransformationBlock: valueTransformationBlock)
    }


    public func valueTransform<Transformed>(with valueTransformationBlock: @escaping (Update) -> Transformed) -> Published<Transformed> where Transformed: AnyObject {
        return Published<Transformed>(withSource: self, valueTransformationBlock: valueTransformationBlock)
    }


    public func valueTransform<Transformed>(with valueTransformationBlock: @escaping (Update) -> Transformed) -> Published<Transformed> where Transformed: AnyObject & Equatable {
        return Published<Transformed>(withSource: self, valueTransformationBlock: valueTransformationBlock)
    }
}
