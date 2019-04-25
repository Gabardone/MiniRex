//
//  Publisher+UpdateTransformer.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 2/1/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


extension Publisher {

    /**
     Builds a Publisher that transform another publisher's updates.

     May be used for any type of Publisher, but for PublishedValue behavior it's better to use the valueTransformation
     API to preserve update only on value change behavior as much as possible.
     - Parameter sourcePublisher: The publisher whose updates are the source for the one we're building.
     - Parameter transformationBlock: A block that converts a source update into one of the kind we want for the
     publisher we're creating.

     The transformationBlock can transform into any type whatsoever, including the source's type, so there is no
     limitation about it other than it has to produce a value for every source update.
     */
    init<OriginalUpdate>(withSource sourcePublisher: Publisher<OriginalUpdate>, transformationBlock: @escaping (OriginalUpdate) -> Update) {
        self.init(withSubscribeBlock: { (updateBlock: @escaping (Update) -> Void) in
            return sourcePublisher.subscribe({ (update) in
                updateBlock(transformationBlock(update))
            })
        })
    }
}


extension Publisher where Update: Equatable {

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
    init<OriginalUpdate>(withSource sourcePublisher: Publisher<OriginalUpdate>, valueTransformationBlock: @escaping (OriginalUpdate) -> Update) {
        self.init(withSubscribeBlock: { (updateBlock: @escaping (Update) -> Void) in
            var cachedValue: Update?
            return sourcePublisher.subscribe({ (update) in
                let newValue = valueTransformationBlock(update)
                if cachedValue == nil || cachedValue! != newValue {
                    cachedValue = newValue
                    updateBlock(newValue)
                }
            })
        })
    }
}


extension Publisher where Update: AnyObject {

    /**
     Builds a Publisher that transform another publisher's updates. It will only update subscribers if the new value
     should update subscribers, by checking for identity.

     If applied to a PublishedValue, will act as another PublishedValue as it will obtain an initial value as soon as
     any subscription happens.
     - Parameter sourcePublisher: The publisher whose updates are the source for the one we're building.
     - Parameter valueTransformationBlock: A block that converts a source update into one of the kind we want for the
     publisher we're creating.

     The transformationBlock can transform into any type whatsoever, including the source's type, so there is no
     limitation about it other than it has to produce a value for every source update.
     */
    init<OriginalUpdate>(withSource sourcePublisher: Publisher<OriginalUpdate>, valueTransformationBlock: @escaping (OriginalUpdate) -> Update) {
        self.init(withSubscribeBlock: { (updateBlock: @escaping (Update) -> Void) in
            var cachedValue: Update?
            return sourcePublisher.subscribe({ (update) in
                let newValue = valueTransformationBlock(update)
                if cachedValue == nil || cachedValue! !== newValue {
                    cachedValue = newValue
                    updateBlock(newValue)
                }
            })
        })
    }
}


extension Publisher {

    /**
     Builds up a publisher that transforms the updates from the caller into new values.
     - Parameter transformationBlock: A block that converts the caller's updates into ones of the kind we want for the
     publisher we're creating.
     - Returns: A publisher whose subscribers will get the same updates as the caller, but transformed by the given
     block.

     The transformationBlock can transform into any type whatsoever, including the source's type, so there is no
     limitation about it other than it has to produce a value for every source update.
     */
    public func transform<Transformed>(with transformationBlock: @escaping (Update) -> Transformed) -> Publisher<Transformed> {
        return Publisher<Transformed>(withSource: self, transformationBlock: transformationBlock)
    }


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
    public func valueTransform<Transformed>(with valueTransformationBlock: @escaping (Update) -> Transformed) -> Publisher<Transformed> where Transformed: Equatable {
        return Publisher<Transformed>(withSource: self, valueTransformationBlock: valueTransformationBlock)
    }


    /**
     Builds up a publisher that transforms the value updates from the caller into new values.

     Unlike the regular transform Publisher that always updates publishers when it gets an update itself, this one will
     only update subscribers if the updated, transformed value is a different object than the last transformed one,
     complying with the expected semantics of a published value as well as possible.

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
    public func valueTransform<Transformed>(with valueTransformationBlock: @escaping (Update) -> Transformed) -> Publisher<Transformed> where Transformed: AnyObject {
        return Publisher<Transformed>(withSource: self, valueTransformationBlock: valueTransformationBlock)
    }
}
