//
//  PublishedValue+KVO.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 10/30/18.
//  Copyright © 2018 Óscar Morales Vivó. All rights reserved.
//

import Foundation
import os


/**
 Extension declaring constructors for KVO published values (initial value + updates).
 */
extension Published {

    /**
     A constructor for a published value that publishes updates to an object's Swift strongly typed KeyPath value.

     This KVO Publisher acts as a published value, sending an update on subscription with the current value, then
     calling the update block whenever the value updates.
     - Parameter object: The object whose keypath value updates we want to publish.
     - Parameter keyPath: The keypath whose updates we want to publish.
     */
    fileprivate init<Root>(forKVOValueUpdatesOf object: Root, keyPath: KeyPath<Root, Update>) where Root: NSObject {
        //  The Swift compiler chokes on this if we try to do it all at once...
        let rawKVOPublisher = Published<(Root, NSKeyValueObservedChange<Update>)>(withSubscribeBlock: object.subscribeBlock(forKeyPath: keyPath, keyValueObservingOptions: [.initial, .new]))
        let transformationBlock = { (update: (object: Root, change: NSKeyValueObservedChange<Update>)) -> Update in
            return update.change.newValue!
        }
        self.init(withSource: rawKVOPublisher, valueTransformationBlock: transformationBlock)
    }

    /**
     A constructor for a published value that publishes updates to an object's string key path value.

     This KVO Publisher acts as a published value, sending an update on subscription with the current value, then
     calling the update block whenever the value updates.

     Behavior is undefined (and most likely a crash) if the string key path points to a value of a different kind than
     expected.
     - Parameter object: The object whose keypath value updates we want to publish.
     - Parameter keyPathString: The keypath whose updates we want to publish.
     */
    fileprivate init(forKVOValueUpdatesOf object: NSObject, keyPathString: String) {
        //  The Swift compiler chokes on this if we try to do it all at once...
        let rawKVOPublisher = Published<(Any?, [NSKeyValueChangeKey: Any]?)>(withSubscribeBlock: object.subscribeBlock(forKeyPathString: keyPathString, keyValueObservingOptions: [.initial, .new]))
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
        self.init(withSource: rawKVOPublisher, valueTransformationBlock: transformationBlock)
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
     Builds up a value publisher to subscribe to a keypath value updates.

     Most of the time you'll just want to subscribe to a Key value observable property and get any updates when it
     changes. Use this method to create an already preconfigured publisher whose subscriptions will just be updated
     on the value itself, including the initial value.
     - Parameter keyPath: A Swift type safe key-path, relative to the calling object, for whose updates will trigger
     calls to the given update block.
     - Returns: A publisher that publishes the key-path's initial value and its updates.
     */
    public func publishedValue<ValueType>(forKeyPathUpdates keyPath: KeyPath<Self, ValueType>) -> Published<ValueType> {
        return Published(forKVOValueUpdatesOf: self, keyPath: keyPath)
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
    public func subscribe<Value>(toValueAtKeyPath keyPath: KeyPath<Self, Value>, update: @escaping (Value) -> Void) -> Subscription {
        let publisher = self.publishedValue(forKeyPathUpdates: keyPath)
        return publisher.subscribe(update)
    }
}


extension NSObject {

    /**
     Builds a raw string key path published value for the calling object.

     Since the original KVO API isn't typed, this method is offered as an extension to NSObject. It's up to the caller
     to make sure the key path is correct and the values returned in the KVO notifications are the expected ones.
     - Parameter keyPathString: A key-path, relative to the calling object, for whose updates the returned publisher will
     trigger calls to the given update block.
     - Returns: A publisher whose subscribers are updated for KVO value updates fitting the given options.
     */
    public func publishedValue<ValueType>(forKeyPathString keyPathString: String) -> Published<ValueType> {
        return Published<ValueType>(forKVOValueUpdatesOf: self, keyPathString: keyPathString)
    }


    /**
     Subscribes to the given string key path value as a published value, updating on initial value and further value
     updates.

     As usual for string key path publications, take care that the type is correct for the key path.
     - Parameter keyPathString: A string key-path, relative to the calling object, for whose value updates will trigger
     calls to the given update block.
     - Parameter update: The value update block that will be called when the value at the given string key path updates.
     - Returns: A subscription object.
     */
    public func subscribe<ValueType>(toValueAtKeyPathString keyPathString: String, update: @escaping (ValueType) -> Void) -> Subscription {
        let publisher: Published<ValueType> = self.publishedValue(forKeyPathString: keyPathString)
        return publisher.subscribe(update)
    }
}
