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
     publisher we're creating.

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
}


extension Task {

    /**
     Builds up a Task that transforms the updates from the caller into new values.

     Note that this can be called on any Publisher but the return is a Broadcaster. This is because we can't make
     any guarantees on the behavior of the result and  Broadcaster models that best. For Published<Value> there's
     a separate API that returns another one.
     - Parameter transformationBlock: A block that converts the caller's updates into ones of the kind we want for
     the publisher we're creating.
     - Returns: A broadcaster whose subscribers will get the same updates as the caller, but transformed by the
     given block.

     The transformationBlock can transform into any type whatsoever, including the source's type, so there is no
     limitation about it other than it has to produce a value for every source update.
     */
    public func transform<TransformedProgress, TransformedSuccess, TransformedFailure>(with transformationBlock: @escaping (Update) -> Task<TransformedProgress, TransformedSuccess, TransformedFailure>.Update) -> Task<TransformedProgress, TransformedSuccess, TransformedFailure> {
        return Task<TransformedProgress, TransformedSuccess, TransformedFailure>(withSource: self, transformationBlock: transformationBlock)
    }
}
