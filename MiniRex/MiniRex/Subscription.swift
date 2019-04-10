//
//  Subscription.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 1/14/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


/**
 Subscription objects are returned by a Publisher's subscribe method and they are meant to be kept as markers that keep
 both the subscription and the subscribed publisher alive.

 Subscription is usually managed by the object's lifetime (also why it has to be a reference type). Optionally it can
 be invalidated early by calling the invalidate() method. Note that even if the Subscription was created with a strong
 reference to its publisher source, invalidating a Subscription will clean that strong reference and may cause the
 publisher to be deallocated.
 */
public final class Subscription {

    /**
     Use this as a singleton in cases where there is nothing to do to unsubscribe (i.e. no updates are forthcoming or
     have all happened during subsription).
     */
    static let empty = Subscription(withUnsubscriber: {})

    /**
     The callback type for the subscription to invalidate itself.
     */
    public typealias UnsubscriberBlock = () -> ()

    /**
     The logic that unsubscribes the subscription.
     */
    private var unsubscriber: (() -> ())?

    /**
     Initializes a subscription with its unsubscribing block. The block will normally maintain a strong reference to
     the publisher this object will be subscribed to.

     Normally only publishers will create these, building up or adapting the unsubscriber block to their needs.
     - Parameter unsubscriber: The block to call to unsubscribe this subscription.
     */
    public init(withUnsubscriber unsubscriber: @escaping () -> ()) {
        self.unsubscriber = unsubscriber
    }

    /**
     Call invalidate to stop receiving updates. Any strong references to the publisher source will also be cleaned up.
     The subscription update block might still be called if it has been dispatched prior to the invalidation and has
     not been executed yet.

     In general it is recommended to avoid calling this method and just own the Subscription objects on a single
     reference that gets removed when the subscription is no longer needed.
     */
    public func invalidate() {
        unsubscriber?()
        unsubscriber = nil
    }

    /**
     Deinitialization causes unsubscription unless it has already been invalidated earlier.
     */
    deinit {
        unsubscriber?()
    }
}
