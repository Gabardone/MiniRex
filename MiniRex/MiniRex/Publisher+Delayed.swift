//
//  Publisher+Delayed.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 10/18/20.
//  Copyright © 2020 Óscar Morales Vivó. All rights reserved.
//

import Foundation


extension DispatchQueue {

    fileprivate static let miniRexDelay = DispatchQueue(label: "org.omv.MiniRex.delay")
}


extension Publisher {


    /**
     Creates a publisher that subscribes at a given point in time.

     This is particularly useful for tasks since subscribing to them starts executing them. It will also delay
     initial updates when subscribing to published values and will prevent receiving any notifications from
     broadcasters.

     - Note: It's best not to rely solely on subscription canceling too much since this functionality involves timers
     and it may be subject to race conditions.
     - Note: Delay happens in a private concurrent queue, subject to change between versions. Make sure to dispatch
     the source publisher's subscription to a known queue if it is important to ensure it executes on a particular
     one.
     - Parameter publisher: The source publisher. We'll be making its subscription happen later.
     - Parameter delay: How long to delay the subscription.
     */
    public init(withSourcePublisher publisher: Self, after delay: DispatchTimeInterval) {
        self.init { (updateBlock) -> Subscription in
            //  We'll be acquiring a lock when either subscribing or unsubscribing as executing both concurrently
            //  can only end in undefined, occasional and impossible to debug tears.
            var unfairLock = os_unfair_lock_s()
            //  This variable is in the scope of this particular subscription so this should work if there's more
            //  than one subscription to the publisher.
            var sourcePublisher: Self? = publisher
            return Subscription(subscriptionWrapper: { (subscriptionBlock) in
                DispatchQueue.miniRexDelay.asyncAfter(deadline: .now() + delay, execute: {
                    os_unfair_lock_lock(&unfairLock)
                    //  We check for sourcePublisher only here so to we ensure we check on the right queue.
                    if let sourcePublisher = sourcePublisher {
                        subscriptionBlock(sourcePublisher.subscribe(updateBlock))
                    }
                    os_unfair_lock_unlock(&unfairLock)
                })
            }, unsubscriptionWrapper: { (unsubscriptionBlock) in
                DispatchQueue.miniRexDelay.async {
                    os_unfair_lock_lock(&unfairLock)
                    //  If we land here we want to make sure subscription doesn't happen.
                    sourcePublisher = nil
                    unsubscriptionBlock()
                    os_unfair_lock_unlock(&unfairLock)
                }
            })
        }
    }


    /**
     Produces a new Publisher based on the caller that dispathces subscribe/unsubscribe operations to the given queue.

     Subscription/Unsubscription operations are dispatched with a barrier as they are semantically write operations.
     - Parameter delay: The delay to wait before subscription happens. See the documentation of
     `init(withSourcePublisher:after:)` for more detail on behavior.
     - Returns: A publisher with the same behavior as the caller but which dispatches subscribe/unsubscribe work to the
     given queue.
     */
    public func dispatch(after delay: DispatchTimeInterval) -> Self {
        return Self(withSourcePublisher: self, after: delay)
    }
}
