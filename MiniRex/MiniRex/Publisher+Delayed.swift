//
//  Publisher+Delayed.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 10/18/20.
//  Copyright © 2020 Óscar Morales Vivó. All rights reserved.
//

import Foundation


extension Publisher {

    /**
     Creates a publisher that subscribes at a given point in time.

     This is particularly useful for tasks since subscribing to them starts executing them. It will also delay
     initial updates when subscribing to published values and will prevent receiving any notifications from
     broadcasters.

     If this publisher goes away before the subscription with the source happens it will cancel that subscription
     - Note: It's best not to rely solely on subscription canceling too much since this functionality involves timers
     and it may be subject to race conditions.
     - Parameter publisher: The source publisher. We'll be making its subscription happen later.
     - Parameter when: When to subscribe to the source publisher.
     */
    public init(withSourcePublisher publisher: Self, after delay: DispatchTimeInterval, subscribeQueue queue: DispatchQueue, dispatchOptions options: DispatchWorkItemFlags = .barrier) {
        self.init { (updateBlock) -> Subscription in
            //  This variable is in the scope of this particular subscription so this should work if there's more
            //  than one subscription to the publisher.
            var sourcePublisher: Self? = publisher
            return Subscription(subscriptionWrapper: { (subscriptionBlock) in
                queue.asyncAfter(deadline: .now() + delay, execute: {
                    //  We check for sourcePublisher only here so to we ensure we check on the right queue.
                    if let sourcePublisher = sourcePublisher {
                        subscriptionBlock(sourcePublisher.subscribe(updateBlock))
                    }
                })
            }, unsubscriptionWrapper: { (unsubscriptionBlock) in
                queue.async(group: nil, qos: .unspecified, flags: options, execute: {
                    //  If we land here we want to make sure subscription doesn't happen.
                    sourcePublisher = nil
                    unsubscriptionBlock()
                })
            })
        }
    }


    /**
     Produces a new Publisher based on the caller that dispathces subscribe/unsubscribe operations to the given queue.

     Subscription/Unsubscription operations are dispatched with a barrier as they are semantically write operations.
     - Parameter queue: The queue where we want subscription and unusbscription operations to happen.
     - Parameter options: Options to use when dispatching subscribe/unsubscribe operations. The default is to dispatch
     them as a barrier as they are smeantically write operations (and will usually behave like that in the ultimate
     publisher source). This flag has no impact on serial queues so it can be left as a default even if it's known
     they are being dispatched to one.
     - Returns: A publisher with the same behavior as the caller but which dispatches subscribe/unsubscribe work to the
     given queue.
     */
    public func dispatch(after delay: DispatchTimeInterval, subscribeQueue queue: DispatchQueue, dispatchOptions options: DispatchWorkItemFlags = .barrier) -> Self {
        return Self(withSourcePublisher: self, after: delay, subscribeQueue: queue, dispatchOptions: options)
    }
}
