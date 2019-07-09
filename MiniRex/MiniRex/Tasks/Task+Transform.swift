//
//  Task+Transform.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 7/1/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


extension Task {

    /**
     Builds a Task that transform another task's updates.

     May be used with any type of Publisher as its source. If you have a Published<Value> and wish to preserve its
     update semantics, used the respective value transform API.
     - Parameter sourcePublisher: The publisher whose updates are the source for the one we're building.
     - Parameter transformationBlock: A block that converts a source update into one of the kind we want for the
     task we're creating.

     The transformationBlock can transform into any type whatsoever, including the source's type, so there is no
     limitation about it other than it has to produce a value for every source update.
     */
    init<OriginalProgress, OriginalSuccess, OriginalFailure>(withSource sourcePublisher: Task<OriginalProgress, OriginalSuccess, OriginalFailure>, transformationBlock: @escaping (Task<OriginalProgress, OriginalSuccess, OriginalFailure>.Update) -> Update) {
        self.init(withSubscribeBlock: { (updateBlock: @escaping UpdateBlock) in
            return sourcePublisher.subscribe({ (update) in
                updateBlock(transformationBlock(update))
            })
        })
    }


    /**
     Builds up a Task that transforms the updates from the caller into new values.

     Note that this can be called on any Task whether it posts progress updates or not, although you'll need to
     add some redundant logic to deal with a progress update that would never be called.
     - Parameter transformationBlock: A block that converts the caller's task updates into one of the type requested
     for the resulting Task.
     - Returns: A Task whose subscribers will get the same updates as the caller, but transformed by the given block.

     The transformationBlock can transform into any type whatsoever, including the source's type, so there is no
     limitation about it other than it has to be able to produce an update for every given task update.
     */
    public func transform<TransformedProgress, TransformedSuccess, TransformedFailure>(with transformationBlock: @escaping (Update) -> Task<TransformedProgress, TransformedSuccess, TransformedFailure>.Update) -> Task<TransformedProgress, TransformedSuccess, TransformedFailure> {
        return Task<TransformedProgress, TransformedSuccess, TransformedFailure>(withSource: self, transformationBlock: transformationBlock)
    }
}


extension Task where Progress == Never {

    /**
     Builds a task that transforms another task's updates for cases where we don't care about progress reporting.

     May be used as long as the resulting task has Never as its progress type. Only needs to transform the result.
     - Parameter sourcePublisher: The publisher whose updates are the source for the one we're building.
     - Parameter resultTransformationBlock: A block that converts a source update's result into one of the kind we
     want for the task we're creating.

     The transformationBlock can transform into any type whatsoever, including the source's type, so there is no
     limitation about it other than it has to produce a value for any given task result. Progress updates will be
     skipped.
     */
    init<OriginalProgress, OriginalSuccess, OriginalFailure>(withSource sourcePublisher: Task<OriginalProgress, OriginalSuccess, OriginalFailure>, resultTransformationBlock: @escaping (Result<OriginalSuccess, OriginalFailure>) -> TaskResult) {
        self.init(withSubscribeBlock: { (updateBlock: @escaping UpdateBlock) in
            return sourcePublisher.subscribe({ (update) in
                switch update {
                case .inProgress(_):
                    break

                case .completed(let result):
                    updateBlock(.completed(withResult: resultTransformationBlock(result)))
                }
            })
        })
    }


    /**
     Builds up a Task that transforms the result from the caller into a new result type, skipping progress updates.

     Note that this can be called on any Task whether it posts progress updates or not.
     - Parameter resultTransformationBlock: A block that converts the caller's task result into one of the type
     requested for the resulting Task.
     - Returns: A Task whose subscribers will get the same result as the caller, but transformed by the given block.

     The resultTransformationBlock can transform into any type whatsoever, including the source's type, so there is
     no limitation about it other than it has to be able to produce a value for every given task result.
     */
    public func transform<TransformedSuccess, TransformedFailure>(with resultTransformationBlock: @escaping (TaskResult) -> Result<TransformedSuccess, TransformedFailure>) -> Task<Never, TransformedSuccess, TransformedFailure> {
        return Task<Never, TransformedSuccess, TransformedFailure>(withSource: self, resultTransformationBlock: resultTransformationBlock)
    }
}
