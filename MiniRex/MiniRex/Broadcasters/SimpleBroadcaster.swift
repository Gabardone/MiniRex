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
final public class SimpleBroadcaster<Update> {

    /**
     The default initializer. Declared public because Swift made us.
     */
    public init() {
    }

    /**
     Broadcasts the given value to all subscribers.
     - Parameter update: The update to call subscribers with.
     */
    public func broadcast(update: Update) {
        for (_, updateBlock) in self.subscribers {
            updateBlock(update)
        }
    }

    private var subscribers: [ObjectIdentifier: Broadcaster<Update>.UpdateBlock] = [:]

    /**
     The publisher for broadcast updates.

     After subscription, any calls to broadcast will trigger a call to the update block as long as the subscription is
     alive. Note that subscription may be delayed if using a dispatch publisher.
     */
    public lazy var broadcaster: Broadcaster<Update> = {
        return Broadcaster<Update>(withSubscribeBlock: { [weak weakSelf = self] (updateBlock) -> Subscription in
            guard let strongSelf = weakSelf else {
                if #available(macOS 10.12, iOS 10, tvOS 10, watchOS 3, *) {
                    os_log("Subscribing to updates for a freed object", dso: #dsohandle, log: OSLog.miniRex, type: .error)
                }
                //  SimpleBroadcaster already going away/gone. Return a dummy subscription and log as this would not work
                //  that great if the subscriber has expectations of getting an initial update.
                return Subscription.empty
            }

            //  We'll define it once we have the subscriber in place so it can be used within the unsubscriber block.
            var subscriptionID: ObjectIdentifier!
            let subscription = Subscription(withUnsubscriber: { [weak weakSelf = strongSelf] in
                guard let strongSelf = weakSelf else {
                    //  Not going to unsubscribe if the original source is gone.
                    return
                }

                strongSelf.subscribers.removeValue(forKey: subscriptionID)
            })

            subscriptionID = ObjectIdentifier(subscription)

            //  Now that we have the subscriptionID we can set up the entry in the subscribers dictionary.
            strongSelf.subscribers[subscriptionID] = { [weak weakSubscription = subscription] (update) in
                guard let _ = weakSubscription else {
                    //  The subscription has already started to go away but we haven't yet removed the entry
                    return
                }

                //  We're here so let's just call the block...
                updateBlock(update)
            }

            return subscription
        })
    }()
}
