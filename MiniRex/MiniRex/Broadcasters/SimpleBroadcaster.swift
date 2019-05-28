//
//  SimpleBroadcaster.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 2/26/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation
import os


/**
 A subscription source for publishers that don't hold a value. It has a method to manually update its subscriptions
 with a value, and holds onto a publisher.
 */
final public class SimpleBroadcaster<Update>: RootPublisher<Broadcaster<Update>> {

    /**
     The default initializer. Declared public because Swift made us.
     */
    public override init() {
    }

    /**
     Broadcasts the given value to all subscribers.
     - Parameter update: The update to call subscribers with.
     */
    public func broadcast(update: Update) {
        self.updateSubscribers(withValue: update)
    }


    /**
     The publisher for broadcast updates.

     After subscription, any calls to broadcast will trigger a call to the update block as long as the subscription is
     alive. Note that subscription may be delayed if using a dispatch publisher.
     */
    public lazy var broadcaster: Broadcaster<Update> = {
        return Broadcaster<Update>(withSubscribeBlock: self.subscriptionBlock)
    }()
}
