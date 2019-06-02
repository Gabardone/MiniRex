//
//  PublishedValue+Broadcaster.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 6/2/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


extension Published {

    /**
     Init with a broadcaster subscription block and a way to fetch the initial value.

     This init takes a broadcaster and an initial value for the new published value. It's the recommended
     way to adapt a Braodcaster to a Published Value.

     Note that once created, the published value will update its current value irrespective of whether it gets any
     new subscribers whenever the broadcaster posts an update.
     - Parameter broadcaster: A broadcaster.
     - Parameter initialValue: An initial value to return to subscribers if they subscribe before the soruce
     broadcaster posts any updates.
     */
    public init(withBroadcaster broadcaster: Broadcaster<Update>, initialValue: Update) {
        let publishedProperty = PublishedProperty<Update>(withInitialValue: initialValue)
        let subscription = broadcaster.subscribe { (value) in
            publishedProperty.value = value
        }

        self.init { [subscription] (valueBlock) -> Subscription in
            //  This is just here so we hold onto subscription for the lifetime of the block 🤷🏽‍♂️
            _ = subscription

            //  Now just return the subscription to the actual broadcaster.
            return publishedProperty.publishedValue.subscribe(valueBlock)
        }
    }
}
