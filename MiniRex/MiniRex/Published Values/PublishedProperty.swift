//
//  PublishedProperty.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 1/9/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation
import os


/**
 A simple type to pack up together a property and a published value for it. Direct access to the property should usually
 be left to the immediate environment, while its publisher can be used to vend as API without establishing
 implementation dependencies.

 Making it into a struct wouldn't work as the act of subscribing/unsubscribing involves a change in the state of the
 type's instance. Besides the publish/subscribe pattern implies reference semantics.
 */
final public class PublishedProperty<Value>: RootPublisher<Published<Value>> {

    /**
     A PublishedProperty requires an initial value to set up.
     - Parameter initialValue: The initial value to store in the value property.
     */
    public init(withInitialValue initialValue: Value) {
        self.valueStorage = initialValue
    }


    private var valueStorage: Value


    /**
     The publisher for value updates.

     As a value publisher, subscribing to it will have your update block called with the value at the time of
     subscription. Do not assume it will happen synchronously during the subscribe(_:) call although it may.

     After the initial value call the update block will be called again whenever value changes.

     - Note: The returned publisher retains the PublishedProperty to guarantee that it lives long enough to update
     new subscribers with an initial value. Keep it around only as long as you need them. Its generated subscriptions
     don't hold a strong reference to anything.
     */
    public var publishedValue: Published<Value> {
        return Published<Value>(withSubscribeBlock: { (updateBlock) -> Subscription in
            let result = super.subscriptionBlock(updateBlock)

            //  Initial update to the subscriber.
            updateBlock(self.valueStorage)

            return result
        })
    }
}


extension PublishedProperty where Value: Equatable {

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

            self.updateSubscribers(withValue: newValue)
        }
    }
}


extension PublishedProperty where Value: AnyObject {

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

            self.updateSubscribers(withValue: newValue)
        }
    }
}


extension PublishedProperty where Value: Equatable & AnyObject {

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

            self.updateSubscribers(withValue: newValue)
        }
    }
}


extension PublishedProperty {

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

            self.updateSubscribers(withValue: newValue)
        }
    }
}
