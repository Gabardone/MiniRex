//
//  Broadcaster.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 4/9/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


/**
 A broadcaster just broadcasts updates to its subscribers. There is no specific limitation to what those may be or
 when they happen, but subscribing to them by itself should have no side effects.

 Examples include notifications and triggered repeating timers.
 */
public struct Broadcaster<Broadcast>: Publisher {

    //  MARK: - Publisher Implementation

    public typealias Update = Broadcast

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


    public let subscribeBlock: (@escaping UpdateBlock) -> Subscription


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
