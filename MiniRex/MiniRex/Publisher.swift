//
//  Publication.swift
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
 */
public struct Publisher<Update> {

    /**
     Custom subscription init.

     By injecting astutely designed logic into the subscription block, we can basically turn one of these structs into
     a variety of adapters or operands working on subscription updates, like filters, type transforms and queue
     dispatch.
     - Parameter subscriberBlock: A block that executes the subscription logic.
     */
    public init(withSubscribeBlock subscribeBlock: @escaping (@escaping (Update) -> ()) -> Subscription) {
        self.subscribeBlock = subscribeBlock
    }


    private let subscribeBlock: (@escaping (Update) -> ()) -> Subscription


    public func subscribe(_ updateBlock: @escaping (Update) -> ()) -> Subscription {
        return self.subscribeBlock(updateBlock)
    }
}
