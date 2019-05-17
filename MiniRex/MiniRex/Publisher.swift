//
//  Publisher.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 1/15/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


/**
 A protocol for a basic publisher. It allows for subscribing blocks that are called back whenever certain conditions
 apply that depend on the specific publisher.

 You normally don't use the Publisher type directly, at least by name, but one of its typealias (Published<...>, Task
 or Broadcaster) to better clear out the expected behavior when subscribing.

 A publisher may retain the source of its updates, so don't keep them around longer than needed in circumstances where
 you may create a retain cycle.
 */
public protocol Publisher {

    associatedtype Update

    typealias UpdateBlock = (Update) -> Void

    typealias SubscriptionBlock = (@escaping UpdateBlock) -> Subscription

    var subscribeBlock: SubscriptionBlock { get }

    /**
     Custom subscription init.

     By injecting astutely designed logic into the subscription block, we can basically turn one of these structs into
     a variety of adapters or operands working on subscription updates, like filters, type transforms and queue
     dispatch.
     - Parameter subscriberBlock: A block that executes the subscription logic.
     */
    init(withSubscribeBlock subscribeBlock: @escaping SubscriptionBlock)


    func subscribe(_ updateBlock: @escaping UpdateBlock) -> Subscription
}
