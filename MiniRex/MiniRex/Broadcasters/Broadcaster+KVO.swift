//
//  Broadcaster+KVO.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 5/14/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


/**
 KVO Publishers are obtained from instances of NSObject since only the properties of Objective-C support KVO.
 */
extension KeyValuePublishing where Self: NSObject {

    /**
     Builds up a broadcaster to subscribe to a KVO observation for the given keypath and options.

     This returns the raw publisher whose updates take both keypath root object and key value observed change
     objects. Most of the time you'll want to get a Published<Value> with the corresponding API, but if something
     else is required this API offers the additional flexibility needed to get updates only, or pre-change updates.
     - Parameter keyPath: A Swift type safe key-path, relative to the calling object, for whose updates will trigger
     calls to the given update block.
     - Parameter options: A combination of the NSKeyValueObservingOptions values that specifies when KVO updates trigger
     and what data is included with them. For possible values, see NSKeyValueObservingOptions.
     - Returns: A publisher whose subscribers are updated for KVO updates fitting the given options.
     */
    public func broadcaster<Value>(forKeyPath keyPath: KeyPath<Self, Value>, keyValueObservingOptions options: NSKeyValueObservingOptions) -> Broadcaster<(Self, NSKeyValueObservedChange<Value>)>  {
        return Broadcaster(withSubscribeBlock: self.subscribeBlock(forKeyPath: keyPath, keyValueObservingOptions: options))
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
    public func subscribe<Value>(toKeyPath keyPath: KeyPath<Self, Value>, keyValueObservingOptions options: NSKeyValueObservingOptions, update: @escaping ((object: Self, change: NSKeyValueObservedChange<Value>)) -> Void) -> Subscription {
        let publisher: Broadcaster<(Self, NSKeyValueObservedChange<Value>)> = self.broadcaster(forKeyPath: keyPath, keyValueObservingOptions: options)
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
    public func broadcaster(forKeyPathString keyPathString: String, keyValueObservingOptions options: NSKeyValueObservingOptions) -> Broadcaster<(Any?, [NSKeyValueChangeKey: Any]?)> {
        return Broadcaster(withSubscribeBlock: self.subscribeBlock(forKeyPathString: keyPathString, keyValueObservingOptions: options))
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
    public func subscribe(toKeyPathString keyPathString: String, keyValueObservingOptions options: NSKeyValueObservingOptions, update: @escaping ((object: Any?, change: [NSKeyValueChangeKey : Any]?)) -> Void) -> Subscription {
        let broadcaster = self.broadcaster(forKeyPathString: keyPathString, keyValueObservingOptions: options)
        return broadcaster.subscribe(update)
    }
}
