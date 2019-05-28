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
     have all happened during subsription). The empty subscription is always invalidated.
     */
    static let empty: Subscription = {
        let result = Subscription(withUnsubscriber: {})
        result.invalidate()
        return result
    }()

    /**
     The callback type for the subscription to invalidate itself.
     */
    public typealias UnsubscriberBlock = () -> Void

    /**
     The logic that unsubscribes the subscription.
     */
    private var unsubscriber: UnsubscriberBlock?

    /**
     Initializes a subscription with its unsubscribing block. The block will normally maintain a strong reference to
     the publisher this object will be subscribed to.

     Normally only publishers will create these, building up or adapting the unsubscriber block to their needs.
     - Parameter unsubscriber: The block to call to unsubscribe this subscription.
     */
    public init(withUnsubscriber unsubscriber: @escaping UnsubscriberBlock) {
        self.unsubscriber = unsubscriber
    }


    /**
     Initializes a subscription by wrapping a block that updates us with another subscription.

     Sometimes you don't have everything in place when you build the subscription. This init allows us to delay
     initialization until our block gets called with the subscription we want to wrap.
     - Parameter subscriptionWrapper: A block that takes a callback to be called with a subscription.
     - Parameter unsubscriptionWrapper: A block that takes the original subscription's unsubscriber block. It should
     execute it at some point.
     */
    public convenience init(subscriptionWrapper wrapper: @escaping (@escaping (Subscription) -> ()) -> (), unsubscriptionWrapper: @escaping (@escaping UnsubscriberBlock) -> ()) {
        //  We need to store the source's unsubscriber in the dispatched subscribe block so we can run it
        //  dispatched to the subscribe queue while the subscriber we return is already freed.
        var sourceSubscription: Subscription?
        var sourceUnsubscriber: Subscription.UnsubscriberBlock?

        wrapper { (subscription: Subscription) in
            sourceSubscription = subscription
            sourceUnsubscriber = subscription.unsubscriber
            sourceSubscription?.unsubscriber = nil
        }

        self.init(withUnsubscriber: {
            //  Start by wiping out the source subscription so weak references get nil-ed. Use .empty in case
            //  we unsubscribe before source subscription happens.
            sourceSubscription = .empty

            //  Then run the actual logic on schedule.
            if let unsubscriber = sourceUnsubscriber {
                unsubscriptionWrapper(unsubscriber)
            }
        })
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
     Returns true if the object is managing an active subscription. Use mostly for testing purposes.
     */
    public var isSubscribed: Bool {
        return self.unsubscriber != nil
    }

    /**
     Deinitialization causes unsubscription unless it has already been invalidated earlier.
     */
    deinit {
        unsubscriber?()
    }
}
