//
//  RootPublisher.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 5/27/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


/**
 A base class for managing a standalone, simple publisher. It takes care of managing subscribers and subscription.

 Subclasses add the additional behavior needed to determine when to update subscribers.
 */
class RootPublisher<PublisherType> where PublisherType: Publisher {


    private var subscribers: [ObjectIdentifier: PublisherType.UpdateBlock] = [:]


    /**
     Updates all the subscribers with the given value.

     Subclasses determine when this gets called.
     - Parameter value: The value to send to the subscribers' update blocks.
     */
    func updateSubscribers(withValue value: PublisherType.Update) {
        for (_, updateBlock) in self.subscribers {
            updateBlock(value)
        }
    }


    /**
     Builds and returns a subscribe block for the instance's publisher. We build a single one per instance since
     it's always the same.
     */
    lazy var publisher: PublisherType = {
        return PublisherType(withSubscribeBlock: { [weak self] (updateBlock) in
            guard let self = self else {
                return .empty
            }

            //  We'll define it once we have the subscriber in place so it can be used within the unsubscriber block.
            var subscriptionID: ObjectIdentifier!
            let subscription = Subscription(withUnsubscriber: { [weak self] in
                guard let self = self else {
                    //  Not going to unsubscribe if the original source is gone.
                    return
                }

                self.subscribers.removeValue(forKey: subscriptionID)
            })

            subscriptionID = ObjectIdentifier(subscription)

            //  Now that we have the subscriptionID we can set up the entry in the subscribers dictionary.
            self.subscribers[subscriptionID] = { [weak weakSubscription = subscription] (update) in
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
