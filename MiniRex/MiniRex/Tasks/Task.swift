//
//  Task.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 4/9/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


/**
 A task is a published value that models a one type operation that allows for subscribing to its result.

 Tasks have a few specific behaviors:
 - A task only updates subscribers once, but ought to eventually update once. It's up to the developer to make sure
 the task has a timeout or otherwise always finishes eventually.
 - Subscribers get a Result value (its associated types depend on how the task has been declared).
 - If the task has been completed at the time of subscription, the subscriber will get an immediate (not necessarily
 synchronous) call with the result of the task.
 - Tasks may not execute until they get at least one subscriber. If you want to ensure a task is run, use a single
 update subscription on it.
 - Some tasks may be canceled if they lose all subscribers before they are completed.
 */
public struct Task<Progress, Success, Failure: Error>: Publisher {

    /**
     The update value sent by a task to its subscribers.
     */
    public enum Status {
        /**
         This value means the task is in progress. Depending on how the task is defined it may have an associated value
         of a type that allows for tracking the progress of the task (a percent of completion, data already processed
         etc.). If the task doesn't offer detailed progress it will just be Void.
         */
        case inProgress(Progress)

        /**
         The task was a success, the accompanying associated data the result of the task.
         */
        case success(withResult: Success)

        /**
         The task failed to execute to completion successfully, the accompanying associated error should detail why.
         */
        case failure(withError: Failure)

        /**
         Often we just want to know whether the task is done or not.
         */
        var isFinalized: Bool {
            switch self {
            case .inProgress(_):
                return false

            default:
                return true
            }
        }
    }


    /**
     Optionally, a task can take a block that is run if the task loses all its subscribers before completion, so it
     can clean up and free any resources since no one actually cares about the result of the task anymore.
     */
    public typealias CancelBlock = () -> Void


    /**
     The block that executes a task. It may synchronously return a task status, usually a base .inProgress result
     to pass on to subscribers, but in some cases if the task is trivially doable synchronously or early validation
     shows it cannot be done it can return a .success or .failure status.
     */
    public typealias TaskBlock = (@escaping UpdateBlock) -> Void


    /**
     Builds up a task publisher with the given logic.
     - Parameter queue: The queue where the task management will happen. The actual task may (and usually will)
     happen elsewhere, but its management needs to happen serially to keep subscriptions/unsubscriptions/task
     completion from stomping on each other. Subscribers will be called in the given queue but that can be easily
     fixed with a dispatch wrapper.
     - Parameter taskBlock: The block that actually executes the task. It gets sent as a parameter another block that
     it has to call once completed one way or another. Calling that block will store the result of the task and call
     subscribers with it.

     taskBlock will only get called once a subscription happens.
     - Parameter cancelBlock: Optionally, a block to be called to cancel the task if all subscribers unsubscribe. If
     nil (the default), no action will be taken whenever the task loses all subscribers.
     */
    public init(inQueue queue: DispatchQueue, withTaskBlock taskBlock: @escaping TaskBlock, cancelBlock: CancelBlock? = nil) {
        //  Will store results if they arrive.
        var taskStatus: Update?
        var subscribers: [ObjectIdentifier: UpdateBlock] = [:]
        var taskStarted = false

        self.init(withSubscribeBlock: { (updateBlock) -> Subscription in
            //  We start by checking whether we actually need to do all the work or we already have a result to send
            //  back.
            if let currentStatus = taskStatus, currentStatus.isFinalized {
                //  Just send back the final result.
                queue.async(group: nil, qos: .unspecified, flags: .barrier, execute: {
                    updateBlock(currentStatus)
                })

                //  No need to do more.
                return Subscription.empty
            }

            var subscriptionID: ObjectIdentifier!
            let subscription = Subscription(withUnsubscriber: {
                //  Unsubscription happens in the given queue to avoid conflicting writing to the task data.
                queue.async(group: nil, qos: .unspecified, flags: .barrier, execute: {
                    subscribers.removeValue(forKey: subscriptionID)

                    if subscribers.isEmpty, let cancelBlock = cancelBlock, !(taskStatus?.isFinalized ?? false) {
                        cancelBlock()
                        taskStarted = false
                    }
                })
            })

            subscriptionID = ObjectIdentifier(subscription)

            //  Everything else gets dispatched to the given queue with a barrier to avoid weird race conditions.
            queue.async(group: nil, qos: .unspecified, flags: .barrier, execute: {
                if let currentStatus = taskStatus, currentStatus.isFinalized {
                    //  Task completed while we were waiting for dispatch, just update back and don't bother with
                    //  anything else.
                    updateBlock(currentStatus)
                    return
                }

                //  Add the subscription to the dictionary.
                subscribers[subscriptionID] = updateBlock

                if !taskStarted {
                    //  Haven't started the task yet. Now that we have a subscriber we will
                    taskStarted = true
                    taskBlock({ (result) in
                        queue.async(group: nil, qos: .unspecified, flags: .barrier, execute: {
                            //  We got a result so we're storing it.
                            taskStatus = result

                            //  Update all existing subscribers.
                            for (_, updateBlock) in subscribers {
                                updateBlock(result)
                            }
                        })
                    })
                }
            })

            return subscription
        })
    }


    /**
     Easy subscription utility so two different blocks can be used to deal with success and failure of the task.

     If both success and failure blocks are nil the returned subscription won't be valid.
     - Parameter success: The block that will be called if and when the task succeeds.
     - Parameter failure: The block that will be called if and when the task fails.
     - Returns: A subscription. Will be invalid if both success and failure are nil.
     */
    public func subscribe(success: ((Success) -> Void)?, failure: ((Failure) -> Void)?) -> Subscription {
        guard success != nil, failure != nil else {
            return Subscription.empty
        }

        return self.subscribe({ (result) in
            switch result {
            case .inProgress(_):
                //  We're ignoring this one.
                return

            case .success(let result):
                success?(result)

            case .failure(let error):
                failure?(error)
            }
        })
    }

    //  MARK: - Publisher Implementation

    public typealias Update = Status

    public let subscribeBlock: (@escaping UpdateBlock) -> Subscription

    /**
     Generally best to avoid this one unless you really need a different task management that still complies with all
     the documented task semantics.
     */
    public init(withSubscribeBlock subscribeBlock: @escaping (@escaping (Task<Progress, Success, Failure>.Status) -> Void) -> Subscription) {
        self.subscribeBlock = subscribeBlock
    }


    public func subscribe(_ updateBlock: @escaping UpdateBlock) -> Subscription {
        return self.subscribeBlock(updateBlock)
    }
}
