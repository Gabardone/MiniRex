//
//  PublishedValue.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 4/9/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


/**
 A published value offers a value of a certain type for subscription. Subscribers will get an initial update with the
 value at the time of subscription, followed by further update calls whenever it changes.

 A published value for an Equatable type will only send updates when the actual value changes per its Equatable
 implementation. A non-equatable reference type will only send updates when the identity of the value changes.

 The source of the published value updates will be retained by a value publishers, otherwise it cannot guarantee an
 initial update to subscribers.
 */
public struct Published<Value>: Publisher {

    //  MARK: - Properties

    //  Subscription block storage.

    //  MARK: - Utilities

    /**
     Init with a broadcaster subscription and a way to fetch the initial value.

     This init can take the exact same subscription block as a broadcaster and an additional one that fetches the
     initial value to return to subscribers.
     - Parameter subscribeBlock: A block that executes the subscription logic. This block should not call back
     subscribers with the value at the time of subscription.
     - Parameter currentValueBlock: A block that returns the current value of the published value, to call back the
     new subscriber with.
     */
    public init(withSubscribeBlock subscribeBlock: @escaping SubscriptionBlock, currentValueBlock: @escaping () -> Value) {
        self.init { (valueBlock) -> Subscription in
            let subscription = subscribeBlock(valueBlock)
            valueBlock(currentValueBlock())
            return subscription
        }
    }


    /**
     Alternate subscription that calls a different block for the initial call with the current value at the time of
     subscription.

     Sometimes you really want to do something different for the initial callback, usually because you're
     initializing your own stuff. For those cases, this subscription helps separate the logic between that initial
     call and further updates.
     - Parameter initialValueBlock: Block called first with the value at the time of subscription. May be called
     synchronously or asynchronously. After it is called it will be disposed of no matter the life time of the
     subscription.
     - Parameter valueUpdateBlock: Block called afterwards with further updates to the subscribed value.
     - Returns: A subscription to the published value.
     */
    public func subscribe(initialValueBlock: @escaping UpdateBlock, valueUpdateBlock: @escaping UpdateBlock) -> Subscription {
        var firstBlock: UpdateBlock? = initialValueBlock
        return self.subscribe({ (value) in
            if let initial = firstBlock {
                firstBlock = nil
                initial(value)
            } else {
                valueUpdateBlock(value)
            }
        })
    }

    //  MARK: - Publisher Implementation

    public typealias Update = Value


    public let subscribeBlock: (@escaping UpdateBlock) -> Subscription


    /**
     Custom subscription init.

     By injecting astutely designed logic into the subscription block, we can basically turn one of these structs
     into a variety of adapters or operands working on subscription updates, like filters, type transforms and queue
     dispatch.
     - Parameter subscriberBlock: A block that executes the subscription logic. The subscription block must ensure it
     always calls back new subscriptions with the current value.
     */
    public init(withSubscribeBlock subscribeBlock: @escaping SubscriptionBlock) {
        self.subscribeBlock = subscribeBlock
    }


    /**
     Subscribes the given block to the published value.

     The given block will be called once with the value at the time of subscription (which may happen synchronously
     or asynchronously) and then afterwards whenever the published value changes.

     If Value is of an Equatable or reference type subscribers will only be called when the actual value is detected
     to change per its equatable implementation or identity respectively.
     - Parameter valueBlock: The block that is called initially with the value at the time of subscription, then
     whenever the value gets updated with the new one.
     - Returns: A subscription to the published value.
     */
    public func subscribe(_ valueBlock: @escaping UpdateBlock) -> Subscription {
        return self.subscribeBlock(valueBlock)
    }
}
