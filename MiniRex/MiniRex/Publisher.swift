//
//  Publisher.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 1/15/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


/**
 A structs that publishes something. It allows for creating subscriptions that are updated with a parameter as per the
 template's instantiation. They can also be easily compounded to chain into a variety of behaviors and to adapt to a
 variety of needs.

 You normally don't use the Publisher type directly, at least by name, but one of its typealias (Published<...>, Task
 or Broadcaster) to better clear out the expected behavior when subscribing.
 */
public struct Publisher<Update> {

    /**
     Custom subscription init.

     By injecting astutely designed logic into the subscription block, we can basically turn one of these structs into
     a variety of adapters or operands working on subscription updates, like filters, type transforms and queue
     dispatch.
     - Parameter subscriberBlock: A block that executes the subscription logic.
     */
    public init(withSubscribeBlock subscribeBlock: @escaping (@escaping (Update) -> Void) -> Subscription) {
        self.subscribeBlock = subscribeBlock
    }


    internal let subscribeBlock: (@escaping (Update) -> Void) -> Subscription


    public func subscribe(_ updateBlock: @escaping (Update) -> Void) -> Subscription {
        return self.subscribeBlock(updateBlock)
    }
}
