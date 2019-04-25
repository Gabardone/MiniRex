//
//  Task.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 4/9/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


/**
 A task is a publisher that models a one type operation that allows for subscribing to its result.

 Tasks have a few specific behaviors:
 - A task only updates subscribers once.
 - Subscribers get a Result value (its associated types depend on how the task has been declared).
 - If the task has been completed at the time of subscription, the subscriber will get an immediate (not necessarily
 synchronous) call with the result of the task.
 - Tasks may not execute until they get at least one subscriber. If you want to ensure a task is run, use a single
 update subscription on it.
 - Some tasks may be canceled if they lose all subscribers before they are completed.
 */
public typealias Task<Success, Failure: Error> = Publisher<Result<Success, Failure>>


extension Task {

    public typealias CancelBlock = () -> Void

    /**
     Builds up a task publisher with the given logic.
     - Parameter queue: The queue where the task management will happen. The actual task may (and usually will) happen
     elsewhere, but its management needs to happen serially to keep subscriptions/unsubscriptions/task completion from
     stomping on each other. Subscribers will be called in the given queue but that can be easily fixed with a dispatch
     wrapper.
     - Parameter taskBlock: The block that actually executes the task. It gets sent as a parameter another block that it
     has to call once completed one way or another. Calling that block will store the result of the task and call subscribers
     with it.

     taskBlock will only get called once a subscription happens.
     - Parameter cancelBlock: Optionally, a block to be called to cancel the task if all subscribers unsubscribe. If
     nil (the default), no action will be taken whenever the task loses all subscribers.
     */
    public init(inQueue queue: DispatchQueue, withTaskBlock taskBlock: @escaping (@escaping (Update) -> (Void)) -> Void, cancelBlock: CancelBlock? = nil) {
        //  Will store results if they arrive.
        var taskResult: Update?
        var subscribers: [ObjectIdentifier: (Update) -> Void] = [:]
        var taskStarted = false

        self.init(withSubscribeBlock: { (updateBlock) -> Subscription in
            if let storedResult = taskResult {
                //  We already got the results. Just call back with them.
                updateBlock(storedResult)

                //  And return an empty subscription since we don't care and won't be updating further.
                return Subscription(withUnsubscriber: {})
            } else {
                var subscriptionID: ObjectIdentifier!
                let subscription = Subscription(withUnsubscriber: {
                    //  Unsubscription happens in the given queue to avoid conflicting writing to the task data.
                    queue.async(group: nil, qos: .unspecified, flags: .barrier, execute: {
                        subscribers.removeValue(forKey: subscriptionID)

                        if subscribers.isEmpty, let cancelBlock = cancelBlock, taskResult == nil {
                            cancelBlock()
                            taskStarted = false
                        }
                    })
                })

                subscriptionID = ObjectIdentifier(subscription)

                //  Everything else gets dispatched to the given queue with a barrier to avoid weird race conditions.
                queue.async(group: nil, qos: .unspecified, flags: .barrier, execute: {
                    //  Add the subscription to the dictionary.
                    subscribers[subscriptionID] = updateBlock

                    if !taskStarted {
                        //  Haven't started the task yet. Now that we have a subscriber we will
                        taskStarted = true
                        taskBlock({ (result) in
                            queue.async(group: nil, qos: .unspecified, flags: .barrier, execute: {
                                //  We got a result so we're storing it.
                                taskResult = result

                                //  Update all existing subscribers.
                                for (_, updateBlock) in subscribers {
                                    updateBlock(result)
                                }
                            })
                        })
                    }
                })

                return subscription
            }
        })
    }


    /**
     Easy subscription utility so two different blocks can be used to deal with success and failure of the task.

     If both success and failure blocks are nil the returned subscription won't be valid.
     - Parameter success: The block that will be called if and when the task succeeds.
     - Parameter failure: The block that will be called if and when the task fails.
     - Returns: A subscription. Will be invalid if both success and failure are nil.
     */
    public func subscribe<Success, Failure>(success: ((Success) -> Void)?, failure: ((Failure) -> Void)?) -> Subscription where Update == Result<Success, Failure> {
        guard success != nil, failure != nil else {
            return Subscription.empty
        }

        return self.subscribe({ (result) in
            switch result {
            case .success(let result):
                success?(result)

            case .failure(let error):
                failure?(error)
            }
        })
    }
}
