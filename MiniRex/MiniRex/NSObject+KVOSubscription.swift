//
//  NSObject+KVOSubscription.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 5/12/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation
import os


//  Protocol song and dance lifted from
//  https://github.com/apple/swift/blob/master/stdlib/public/SDK/Foundation/NSObject.swift
//  We want similar behavior when using the method in subclasses of NSObject.
public protocol KVOSubscription {}
extension NSObject : KVOSubscription {}


/**
 KVO Subscription blocks are obtained from instances of NSObject since only the properties of Objective-C support
 KVO.
 */
extension KVOSubscription where Self: NSObject {

    /**
     Builds up a subscribing block to subscribe to a KVO observation for the given keypath and options.

     This returns the raw publisher whose updates take both keypath root object and key value observed change
     objects. Normally you'll want to use the default one that calls with the value only.
     - Parameter keyPath: A Swift type safe key-path, relative to the calling object, for whose updates will trigger
     calls to the given update block.
     - Parameter options: A combination of the NSKeyValueObservingOptions values that specifies when KVO updates
     trigger and what data is included with them. For possible values, see NSKeyValueObservingOptions.
     - Returns: A publisher whose subscribers are updated for KVO updates fitting the given options.
     */
    public func subscribeBlock<Value>(forKeyPath keyPath: KeyPath<Self, Value>, keyValueObservingOptions options: NSKeyValueObservingOptions) -> (@escaping (((Self, NSKeyValueObservedChange<Value>))) -> Void) -> Subscription {
        return { [weak weakObject = self] (updateBlock: @escaping (((Self, NSKeyValueObservedChange<Value>))) -> Void) -> Subscription in
            guard let object = weakObject else {
                if #available(macOS 10.12, iOS 10, tvOS 10, watchOS 3, *) {
                    os_log("Subscribing to KVO updates for a freed object", dso: #dsohandle, log: OSLog.miniRex, type: .error)
                }
                //  Return a dummy subscription, the original object no longer exists.
                return Subscription.empty
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


    /**
     Builds up a subscribing block to subscribe to a KVO observation for the given string keypath and options.

     This returns the raw publisher whose updates take both keypath root object and key value observed change
     objects. Normally you'll want to use the default one that calls with the value only.
     - Parameter keyPath: A Swift type safe key-path, relative to the calling object, for whose updates will trigger
     calls to the given update block.
     - Parameter options: A combination of the NSKeyValueObservingOptions values that specifies when KVO updates
     trigger and what data is included with them. For possible values, see NSKeyValueObservingOptions.
     - Returns: A publisher whose subscribers are updated for KVO updates fitting the given options.
     */
    public func subscribeBlock(forKeyPathString keyPathString: String, keyValueObservingOptions options: NSKeyValueObservingOptions) -> (@escaping ((Any?, [NSKeyValueChangeKey: Any]?)) -> Void) -> Subscription {
        return { [weak weakObject = self] (updateBlock: @escaping ((Any?, [NSKeyValueChangeKey: Any]?)) -> Void) -> Subscription in
            guard let object = weakObject else {
                if #available(macOS 10.12, iOS 10, tvOS 10, watchOS 3, *) {
                    os_log("Subscribing to KVO updates for a freed object", dso: #dsohandle, log: OSLog.miniRex, type: .error)
                }
                //  Return a dummy subscription, the original object no longer exists.
                return Subscription.empty
            }

            //  Observe the expected keypath/object. No need to use context as the observer object only observs one thing.
            let observer = KVOObserver(with: updateBlock)
            object.addObserver(observer, forKeyPath: keyPathString, options: options, context: nil)

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


/*
 Used by the string key path methods to do the actual KVO observation.
 */
private class KVOObserver: NSObject {

    init(with updateBlock: @escaping ((object: Any?, change: [NSKeyValueChangeKey : Any]?)) -> Void) {
        self.updateBlock = updateBlock
    }

    let updateBlock: ((object: Any?, change: [NSKeyValueChangeKey : Any]?)) -> Void

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        updateBlock((object, change))
    }
}
