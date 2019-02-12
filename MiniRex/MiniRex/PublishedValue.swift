//
//  PublishedValue.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 1/9/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation
import os


/**
 A simple type to pack up together a property and a publisher for it. Direct access to the property should usually be
 left to the immediate environment, while its publisher can be used to vend as API without establishing implementation
 dependencies.

 Making it into a struct wouldn't work as the act of subscribing/unsubscribing involves a change in the state of the
 type's instance. Besides the publish/subscribe pattern implies reference semantics.

 - TODO: Multithreading considerations. Exclusive access to subscribers dictionary should take care of most of the
 potential issues and thus might be worthwhile. Otherwise we'd need to just declare that these objects should only be
 accessed from a specific thread (itself a valid approach with some extra help from dispatching publishers).
 */
public class PublishedValue<Value> {

    /**
     A PublishedValue requires an initial value to set up.
     - Parameter initialValue: The initial value to store in the value property.
     */
    public init(withInitialValue initialValue: Value) {
        self.valueStorage = initialValue
    }


    private var valueStorage: Value


    private var subscribers: [ObjectIdentifier: (Value) -> ()] = [:]

    /**
     The publisher for value updates.

     As a value publisher, subscribing to it will have your update block called with the value at the time of
     subscription. Do not assume it will happen synchronously during the subscribe(_:) call although it may.

     After the initial value call the update block will be called again whenever value changes.
     */
    public lazy var publisher: Publisher<Value> = {
        return Publisher<Value>(withSubscribeBlock: { [weak weakSelf = self] (updateBlock) -> Subscription in
            guard let strongSelf = weakSelf else {
                if #available(macOS 10.12, iOS 10, tvOS 10, watchOS 3, *) {
                    os_log("Subscribing to updates for a freed object", dso: #dsohandle, log: OSLog.miniRex, type: .error)
                }
                //  PublishedValue already going away/gone. Return a dummy subscription and log as this would not work
                //  that great if the subscriber has expectations of getting an initial update.
                return Subscription(withUnsubscriber: {})
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

            //  Finally do an initial update call with the current value.
            updateBlock(strongSelf.valueStorage)

            return subscription
        })
    }()
}


extension PublishedValue where Value: Equatable {

    /**
     The value that is being published. You can access this from its local environment and changing it will trigger
     subscriber update calls.
     */
    public var value: Value {
        get {
            return valueStorage
        }

        set {
            let oldValue = self.valueStorage
            guard newValue != oldValue else {
                return
            }

            self.valueStorage = newValue

            guard !self.subscribers.isEmpty else {
                //  No need for post-processing
                return
            }

            //  Broadcast to publishers...
            for (_, updateBlock) in subscribers {
                updateBlock(value)
            }
        }
    }
}


extension PublishedValue where Value: AnyObject {

    /**
     The value that is being published. You can access this from its local environment and changing it will trigger
     subscriber update calls.
     */
    public var value: Value {
        get {
            return valueStorage
        }

        set {
            let oldValue = self.valueStorage
            guard newValue !== oldValue else {
                return
            }

            self.valueStorage = newValue

            guard !self.subscribers.isEmpty else {
                //  No need for post-processing
                return
            }

            //  Broadcast to publishers...
            for (_, updateBlock) in subscribers {
                updateBlock(value)
            }
        }
    }
}


extension PublishedValue where Value: Equatable & AnyObject {

    /**
     The value that is being published. You can access this from its local environment and changing it will trigger
     subscriber update calls.
     */
    public var value: Value {
        get {
            return valueStorage
        }

        set {
            let oldValue = self.valueStorage
            guard newValue != oldValue else {
                return
            }

            self.valueStorage = newValue

            guard !self.subscribers.isEmpty else {
                //  No need for post-processing
                return
            }

            //  Broadcast to publishers...
            for (_, updateBlock) in subscribers {
                updateBlock(value)
            }
        }
    }
}


extension PublishedValue {

    /**
     The value that is being published. You can access this from its local environment and changing it will trigger
     subscriber update calls.
     */
    public var value: Value {
        get {
            return valueStorage
        }

        set {
            self.valueStorage = newValue

            guard !self.subscribers.isEmpty else {
                //  No need for post-processing
                return
            }

            //  Broadcast to publishers...
            for (_, updateBlock) in subscribers {
                updateBlock(value)
            }
        }
    }
}
