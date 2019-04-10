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
typealias Task<ResultType, ErrorType: Error> = Publisher<Result<ResultType, ErrorType>>


extension Task {

    /**
     Builds up a task publisher with the given logic.
     - Parameter taskBlock: The block that actually executes the task. It gets sent as a parameter another block that it
     has to call once completed one way or another. Calling that block will store the result of the task and call subscribers
     with it.

     taskBlock will only get called once a subscription happens.
     - Parameter cancelBlock: Optionally, a block to be called to cancel the task if all subscribers unsubscribe. If
     nil (the default), no action will be taken whenever the task loses all subscribers.
     */
    init(withTaskBlock taskBlock: @escaping ((Update) -> (Void)) -> (Void), cancelBlock: (() -> ())? = nil) {
        //  Will store results if they arrive.
        var taskResult: Update?
        var subscribers: [ObjectIdentifier: (Update) -> ()] = [:]
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
                    subscribers.removeValue(forKey: subscriptionID)

                    if subscribers.isEmpty, let cancelBlock = cancelBlock {
                        cancelBlock()
                        taskStarted = false
                    }
                })

                subscriptionID = ObjectIdentifier(subscription)

                //  Add the subscription to the dictionary.
                subscribers[subscriptionID] = updateBlock

                if !taskStarted {
                    //  Haven't started the task yet. Now that we have a subscriber we will
                    taskStarted = true
                    taskBlock({ (result) in
                        //  We got a result so we're storing it.
                        taskResult = result

                        //  Update all existing subscribers.
                        for (_, updateBlock) in subscribers {
                            updateBlock(result)
                        }
                    })
                }

                return subscription
            }
        })
    }
}
