//
//  Publisher+UpdateTransformer.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 2/1/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


extension Broadcaster {

    /**
     Builds a Broadcaster that transform another publisher's updates.

     May be used with any type of Publisher as its source. If you have a Published<Value> and wish to preserve its
     update semantics, used the respective value transform API.
     - Parameter sourcePublisher: The publisher whose updates are the source for the one we're building.
     - Parameter transformationBlock: A block that converts a source update into one of the kind we want for the
     publisher we're creating.

     The transformationBlock can transform into any type whatsoever, including the source's type, so there is no
     limitation about it other than it has to produce a value for every source update.
     */
    init<OriginalPublisher>(withSource sourcePublisher: OriginalPublisher, transformationBlock: @escaping (OriginalPublisher.Update) -> Update) where OriginalPublisher: Publisher {
        self.init(withSubscribeBlock: { (updateBlock: @escaping UpdateBlock) in
            return sourcePublisher.subscribe({ (update) in
                updateBlock(transformationBlock(update))
            })
        })
    }
}


extension Publisher {

    /**
     Builds up a broadcaster that transforms the updates from the caller into new values.

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
    public func transform<Transformed>(with transformationBlock: @escaping (Update) -> Transformed) -> Broadcaster<Transformed> {
        return Broadcaster<Transformed>(withSource: self, transformationBlock: transformationBlock)
    }
}
