//
//  Publisher+Dispatch.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 2/16/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


extension Publisher {

    /**
     Creates a publisher that subscribes and unsubscribe on a given queue.

     This allows a component that coordinates its operations on a given queue to vend publishers that
     subscribe/unsubscribe on that queue. Since subscribing and unsubscribing are mutating operations on the root
     publisher, the operations are dispatched with a barrier to the given queue.

     - Note: publishers created with this (or those that have one of these as their sources) will not subscribe nor
     unsubscribe synchronously. That means initial udpate calls for value publishers won't happen during the
     subscription call, and that you may get an update call after the logic has ostensibly unsubscribed (if it was
     dispatched before the source subscriber did its thing).
     - Parameter publisher: The source publisher. We'll be making its subscription and unusbscription operations happen
     on the queue parameter.
     - Parameter queue: The queue where we want subscription and unusbscription operations to happen.
     - Parameter options: Options to use when dispatching subscribe/unsubscribe operations. The default is to dispatch
     them as a barrier as they are smeantically write operations (and will usually behave like that in the ultimate
     publisher source). This flag has no impact on serial queues so it can be left as a default even if it's known
     they are being dispatched to one.
     */
    init(withSourcePublisher publisher: Publisher, subscribeQueue queue: DispatchQueue, dispatchOptions options: DispatchWorkItemFlags = .barrier) {
        self.init { (updateBlock) -> Subscription in
            //  We need to store the source's subscription in the dispatched subscribe block so we can dispatch it again
            //  on the returned unsubscriber.
            var sourceSubscription: Subscription?

            //  Subscription happens asynchronously in sourceQueue. Subscription is a mutating operation for the
            //  original publisher so it has to happen on a barrier block.
            queue.async(group: nil, qos: .unspecified, flags: options.union(.barrier), execute: {
                sourceSubscription = publisher.subscribeBlock(updateBlock)
            })

            //  Returned Subscription object will catch on the object returned by the dispatched subscription and again
            //  dispatch its work to sourceQueue.
            return Subscription(withUnsubscriber: {
                queue.async(group: nil, qos: .unspecified, flags: options, execute: {
                    sourceSubscription?.invalidate()
                    sourceSubscription = nil
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
    func dispatch(subscribeQueue queue: DispatchQueue, dispatchOptions options: DispatchWorkItemFlags = .barrier) -> Publisher {
        return Publisher(withSourcePublisher: self, subscribeQueue: queue, dispatchOptions: options)
    }


    /**
     Creates a publisher that dispatches calls to its subscribers' update blocks to the given queue.

     This makes it easy to guarantee that update calls will happen in the desired dispatch queue.
     - Note: publishers created with this (or those that have one of these as their sources) will not subscribe nor
     unsubscribe synchronously. That means initial udpate calls for value publishers won't happen during the
     subscription call, and that you may get an update call after the logic has ostensibly unsubscribed (if it was
     dispatched before the source subscriber did its thing).
     - Parameter publisher: The source publisher. We'll be making its subscription and unusbscription operations happen
     on the queue parameter.
     - Parameter queue: The queue where we want subscription and unusbscription operations to happen.
     - Parameter options: Options to use when dispatching update calls. The default is to dispatch
     them as a barrier as those callbacks will usually lead to mutations in the subscriber's environment. This flag has
     no impact on serial queues so it can be left as a default even if it's known
     they are being dispatched to one.
     */
    init(withSourcePublisher publisher: Publisher, updateQueue queue: DispatchQueue, dispatchOptions options: DispatchWorkItemFlags = .barrier) {
        self.init { (updateBlock) -> Subscription in
            //  Subscribe operation remains the same as source, but we wrap the incoming update blocks in an async
            //  dispatch to our queue of choice.
            return publisher.subscribe({ (update) in
                queue.async(group: nil, qos: .unspecified, flags: options, execute: {
                    updateBlock(update)
                })
            })
        }
    }


    /**
     Produces a new Publisher based on the caller that dispathces updates to the given queue.

     Calls to subscriber update blocks are dispatched with a barrier as they are semantically write operations.
     - Parameter queue: The queue where we want subscription update calls to happen.
     - Parameter options: Options to use when dispatching update calls. The default is to dispatch
     them as a barrier as those callbacks will usually lead to mutations in the subscriber's environment. This flag has
     no impact on serial queues so it can be left as a default even if it's known
     they are being dispatched to one.
     - Returns: A publisher with the same behavior as the caller but which dispatches subscription update calls to the
     given queue.
     */
    func dispatch(updateQueue queue: DispatchQueue, dispatchOptions options: DispatchWorkItemFlags = .barrier) -> Publisher {
        return Publisher(withSourcePublisher: self, updateQueue: queue, dispatchOptions: options)
    }
}
