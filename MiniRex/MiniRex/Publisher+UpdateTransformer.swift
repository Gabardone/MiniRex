//
//  Publisher+UpdateTransformer.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 2/1/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


extension Publisher {

    /**
     Builds a Publication that transform another publisher's updates.
     - Parameter sourcePublisher: The publisher whose updates are the source for the one we're building.
     - Parameter transformationBlock: A block that converts a source update into one of the kind we want for the
     publisher we're creating.

     The transformationBlock can transform into any type whatsoever, including the source's type, so there is no
     limitation about it other than it has to produce a value for every source update.
     */
    init<OriginalUpdate>(withSource sourcePublisher: Publisher<OriginalUpdate>, transformationBlock: @escaping (OriginalUpdate) -> Update) {
        self.init(withSubscribeBlock: { (updateBlock: @escaping (Update) -> ()) in
            return sourcePublisher.subscribe({ (update) in
                updateBlock(transformationBlock(update))
            })
        })
    }
}


extension Publisher {

    /**
     Builds up a publisher that transforms the updates from the caller into new values.
     - Parameter transformationBlock: A block that converts the caller's updates into ones of the kind we want for the
     publisher we're creating.
     - Returns: A publisher whose subscribers will get the same updates as the caller, but transformed by the given
     block.

     The transformationBlock can transform into any type whatsoever, including the source's type, so there is no
     limitation about it other than it has to produce a value for every source update.
     */
    public func transform<Transformed>(with transformationBlock: @escaping (Update) -> Transformed) -> Publisher<Transformed> {
        return Publisher<Transformed>(withSource: self, transformationBlock: transformationBlock)
    }
}
