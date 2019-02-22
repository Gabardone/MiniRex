//
//  KVOPublisher.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 10/30/18.
//  Copyright © 2018 Óscar Morales Vivó. All rights reserved.
//

import Foundation
import os


/**
 Publication extension for strongly typed key-path KVO update publication. The update block parameter will be the same
 as for the Swift KVO Api (tuple of root object and NSKeyValueObservedChange struct).
 */
extension Publisher {

    /**
     Builds up a Publication for the KVO updates for the given Swift type safe key-path applied to the given object.
     - Parameter object: The object rooting the keypath we want to observe. Note that the object is not retained by the
     publication. If it gets freed before a subscription to the publication happens, the subscription will be a dud (it
     will never publish any updates) and an error will be logged to console.
     - Parameter keyPath: The Swift type-checked keypath we want to to observe on object.
     - Parameter keyValueObservingOptions: Options for the key-value observation. See the Foundation documentation for
     possible values.
     */
    fileprivate init<Root, Value>(forKVOObservationOf object: Root, keyPath: KeyPath<Root, Value>, keyValueObservingOptions options: NSKeyValueObservingOptions) where Root: NSObject, Update == (Root, NSKeyValueObservedChange<Value>) {
        self.init { [weak weakObject = object] (updateBlock) -> Subscription in
            guard let object = weakObject else {
                if #available(macOS 10.12, iOS 10, tvOS 10, watchOS 3, *) {
                    os_log("Subscribing to KVO updates for a freed object", dso: #dsohandle, log: OSLog.miniRex, type: .error)
                }
                //  Return a dummy subscription, the original object no longer exists.
                return Subscription(withUnsubscriber: {})
            }

            //  Observe the expected keypath/object.
            let observer = object.observe(keyPath, options: options) { (object, change) in
                updateBlock((object, change))
            }

            //  Build and return the subscription.
            return Subscription(withUnsubscriber: {
                //  Manually invalidate (this is safe even if the observed property's owner has already gone away).
                observer.invalidate()
            })

        }
    }
}


/**
 Publication extension for weakly typed (String) key-path KVO update publication. The update block parameter will be the
 same as for the NSObject observation API (tuple of root object and change dictionary keyed by NSKeyValueChangeKey).
 */
extension Publisher where Update == (Any?, [NSKeyValueChangeKey: Any]?) {

    private class KVOObserver: NSObject {

        init(with updateBlock: @escaping ((object: Any?, change: [NSKeyValueChangeKey : Any]?)) -> ()) {
            self.updateBlock = updateBlock
        }

        let updateBlock: ((object: Any?, change: [NSKeyValueChangeKey : Any]?)) -> ()

        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            updateBlock((object, change))
        }
    }


    /**
     Builds up a Publication for the value of the given string key-path applied to the given object.
     - Parameter object: The object rooting the keypath we want to observe. Note that the object is not retained by the
     publication. If it gets freed before a subscription to the publication happens, the subscription will be a dud (it
     will never publish any updates) and an error will be logged to console.
     - Parameter keyPathString: The string keypath we want to to observe on object. It's up to the developer using the API to
     verify that it's a correct key path for the given object.
     - Parameter keyValueObservingOptions: Options for the key-value observation. See the Foundation documentation for
     possible values.
     */
    fileprivate init(forKVOObservationOf object: NSObject, keyPathString: String, keyValueObservingOptions: NSKeyValueObservingOptions) {
        self.init { [weak weakObject = object] (updateBlock) -> Subscription in
            guard let object = weakObject else {
                if #available(macOS 10.12, iOS 10, tvOS 10, watchOS 3, *) {
                    os_log("Subscribing to KVO updates for a freed object", dso: #dsohandle, log: OSLog.miniRex, type: .error)
                }
                //  Return a dummy subscription, the original object no longer exists.
                return Subscription(withUnsubscriber: {})
            }

            //  Observe the expected keypath/object. No need to use context as the observer object only observs one thing.
            let observer = KVOObserver(with: updateBlock)
            object.addObserver(observer, forKeyPath: keyPathString, options: keyValueObservingOptions, context: nil)

            //  Build and return the subscription.
            return Subscription(withUnsubscriber: { [weak weakObject = object] in
                //  Manually invalidate (this is safe even if the observed property's owner has already gone away).
                guard let object = weakObject else {
                    //  Already got freed, nothing to do here.
                    return
                }

                object.removeObserver(observer, forKeyPath: keyPathString)
            })
        }
    }
}


/**
 Extension declaring constructors for key value update observation (initial value + updates).
 */
extension Publisher {

    /**
     A constructor for a Publication that publishes updates to an object's Swift strongly typed KeyPath value.

     This Publication acts as a value publisher, sending an update on subscription with the current value, then
     calling the update block whenever the value updates.
     - Parameter object: The object whose keypath value updates we want to publish.
     - Parameter keyPath: The keypath whose updates we want to publish.
     */
    fileprivate init<Root>(forKVOValueUpdatesOf object: Root, keyPath: KeyPath<Root, Update>) where Root: NSObject {
        //  The Swift compiler chokes on this if we try to do it all at once...
        let rawKVOPublication = Publisher<(Root, NSKeyValueObservedChange<Update>)>(forKVOObservationOf: object, keyPath: keyPath, keyValueObservingOptions: [.initial, .new])
        let transformationBlock = { (update: (object: Root, change: NSKeyValueObservedChange<Update>)) -> Update in
            return update.change.newValue!
        }
        self.init(withSource: rawKVOPublication, transformationBlock: transformationBlock)
    }

    /**
     A constructor for a Publication that publishes updates to an object's string key path value.

     This Publication acts as a value publisher, sending an update on subscription with the current value, then
     calling the update block whenever the value updates.

     Behavior is undefined (and most likely a crash) if the string key path points to a value of a different kind than
     expected.
     - Parameter object: The object whose keypath value updates we want to publish.
     - Parameter keyPathString: The keypath whose updates we want to publish.
     */
    fileprivate init(forKVOValueUpdatesOf object: NSObject, keyPathString: String) {
        //  The Swift compiler chokes on this if we try to do it all at once...
        let rawKVOPublication = Publisher<(Any?, [NSKeyValueChangeKey: Any]?)>(forKVOObservationOf: object, keyPathString: keyPathString, keyValueObservingOptions: [.initial, .new])
        let transformationBlock = { (update: (object: Any?, change: [NSKeyValueChangeKey: Any]?)) -> Update in
            switch update.change![.newKey] {
            case let value as Update:
                //  This should be always the case for non-optionals, and for non-nil optional values.
                return value

            case _ as NSNull:
                //  This will be hit if the observerd property is nullable/optional
                let nilValue: Any? = nil
                return nilValue as! Update

            default:
                //  Programmer error, most likely.
                preconditionFailure("Unknown type for new value posted on KVO notification with change \(String(describing: update.change))")
            }
        }
        self.init(withSource: rawKVOPublication, transformationBlock: transformationBlock)
    }
}


//  Protocol song and dance lifted from https://github.com/apple/swift/blob/master/stdlib/public/SDK/Foundation/NSObject.swift
//  We want similar behavior when using the method in subclasses of NSObject.
public protocol KeyValuePublishing {}
extension NSObject : KeyValuePublishing {}

/**
 KVO Publishers are obtained from instances of NSObject since only the properties of Objective-C support KVO.
 */
extension KeyValuePublishing where Self: NSObject {

    /**
     Builds up a publisher to subscribe to a KVO observation for the given keypath and options.

     This returns the raw publisher whose updates take both keypath root object and key value observed change objects.
     Normally you'll want to use the default one that calls with the value only.
     - Parameter keyPath: A Swift type safe key-path, relative to the calling object, for whose updates will trigger
     calls to the given update block.
     - Parameter options: A combination of the NSKeyValueObservingOptions values that specifies when KVO updates trigger
     and what data is included with them. For possible values, see NSKeyValueObservingOptions.
     - Returns: A publisher whose subscribers are updated for KVO updates fitting the given options.
     */
    public func publisher<Value>(forKeyPath keyPath: KeyPath<Self, Value>, keyValueObservingOptions options: NSKeyValueObservingOptions) -> Publisher<(Self, NSKeyValueObservedChange<Value>)> {
        return Publisher(forKVOObservationOf: self, keyPath: keyPath, keyValueObservingOptions: options)
    }

    /**
     Builds up a value publisher to subscribe to a keypath value updates.

     Most of the time you'll just want to subscribe to a Key value observable property and get any updates when it
     changes. Use this method to create an already preconfigured publisher whose subscriptions will just be updated
     on the value itself, including the initial value.
     - Parameter keyPath: A Swift type safe key-path, relative to the calling object, for whose updates will trigger
     calls to the given update block.
     - Returns: A publisher that publishes the key-path's initial value and its updates.
     */
    public func publisher<Value>(forKeyPathUpdates keyPath: KeyPath<Self, Value>) -> Publisher<Value> {
        return Publisher(forKVOValueUpdatesOf: self, keyPath: keyPath)
    }

    /**
     Subscribes to the given key path with the given options, updating with the same values that the Swift typed KVO API
     gets.

     Use this if you need custom observing options other than just value updates. The subscribing block will be called
     whenever the key value observation triggers.
     - Parameter keyPath: A Swift type safe key-path, relative to the calling object, for whose updates will trigger
     calls to the given update block.
     - Parameter options: A combination of the NSKeyValueObservingOptions values that specifies when KVO updates trigger
     and what data is included with them. For possible values, see NSKeyValueObservingOptions.
     - Parameter update: The subscription update block that will be called when KVO updates happen.
     - Returns: A subscription object.
     */
    public func subscribe<Value>(toKeyPath keyPath: KeyPath<Self, Value>, keyValueObservingOptions options: NSKeyValueObservingOptions, update: @escaping ((object: Self, change: NSKeyValueObservedChange<Value>)) -> ()) -> Subscription {
        let publisher = self.publisher(forKeyPath: keyPath, keyValueObservingOptions: options)
        return publisher.subscribe(update)
    }

    /**
     Subscribes to the value for the given key path.

     As a value subscription, the update block will be called once with the value at the time of subscription and then
     whenever it updates.
     - Parameter keyPath: A Swift type safe key-path, relative to the calling object, for whose updates will trigger
     calls to the given update block.
     - Parameter update: The subscription update block that will be called when key path value changes.
     - Returns: A subscription object.
     */
    public func subscribe<Value>(toKeyPathUpdates keyPath: KeyPath<Self, Value>, update: @escaping (Value) -> ()) -> Subscription {
        let publisher = self.publisher(forKeyPathUpdates: keyPath)
        return publisher.subscribe(update)
    }
}


extension NSObject {

    /**
     Builds a raw string key path publisher for the calling object.

     Since the original KVO API isn't typed, this method is offered as an extension to NSObject. It's up to the caller
     to make sure the key path is correct and the types returned in the KVO notifications are the expected ones.
     - Parameter keyPathString: A key-path, relative to the calling object, for whose updates the returned publisher will
     trigger calls to the given update block.
     - Parameter options: A combination of the NSKeyValueObservingOptions values that specifies when KVO updates trigger
     and what data is included with them. For possible values, see NSKeyValueObservingOptions.
     - Returns: A publisher whose subscribers are updated for KVO updates fitting the given options.
     */
    public func publisher(forKeyPathString keyPathString: String, keyValueObservingOptions options: NSKeyValueObservingOptions) -> Publisher<(Any?, [NSKeyValueChangeKey: Any]?)> {
        return Publisher(forKVOObservationOf: self, keyPathString: keyPathString, keyValueObservingOptions: options)
    }

    /**
     Builds a raw string key path value publisher for the calling object.

     Since the original KVO API isn't typed, this method is offered as an extension to NSObject. It's up to the caller
     to make sure the key path is correct and the values returned in the KVO notifications are the expected ones.
     - Parameter keyPathString: A key-path, relative to the calling object, for whose updates the returned publisher will
     trigger calls to the given update block.
     - Returns: A publisher whose subscribers are updated for KVO value updates fitting the given options.
     */
    public func publisher<Value>(forKeyPathString keyPathString: String) -> Publisher<Value> {
        return Publisher(forKVOValueUpdatesOf: self, keyPathString: keyPathString)
    }

    /**
     Subscribes to the given string key path with the given options, updating with the same values that the unsafe
     String KVO API gets.

     Generally avoid using this raw without adapters, although it allows for the maximum possible flexibility on KVO
     subscriptions. The subscribing block will be called whenever the key value observation triggers.
     - Parameter keyPathString: A string key-path, relative to the calling object, for whose updates will trigger calls to the
     given update block.
     - Parameter options: A combination of the NSKeyValueObservingOptions values that specifies when KVO updates trigger
     and what data is included with them. For possible values, see NSKeyValueObservingOptions.
     - Parameter update: The subscription update block that will be called when KVO updates happen.
     - Returns: A subscription object.
     */
    public func subscribe(toKeyPathString keyPathString: String, keyValueObservingOptions options: NSKeyValueObservingOptions, update: @escaping ((object: Any?, change: [NSKeyValueChangeKey : Any]?)) -> ()) -> Subscription {
        let publisher = self.publisher(forKeyPathString: keyPathString, keyValueObservingOptions: options)
        return publisher.subscribe(update)
    }

    /**
     Subscribes to the given string key path value, updating on initial value and further value updates.

     As usual for string key path publications, take care that the type is correct for the key path.
     - Parameter keyPathString: A string key-path, relative to the calling object, for whose value updates will trigger
     calls to the given update block.
     - Parameter update: The value update block that will be called when the value at the given string key path updates.
     - Returns: A subscription object.
     */
    public func subscribe<Update>(toKeyPathStringUpdates keyPathString: String, update: @escaping (Update) -> ()) -> Subscription {
        let publisher: Publisher<Update> = self.publisher(forKeyPathString: keyPathString)
        return publisher.subscribe(update)
    }
}
