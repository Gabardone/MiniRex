//
//  Broadcaster+Filter.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 4/24/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


extension Broadcaster {

    /**
     Builds a Broadcaster that filters another publisher's updates.

     The init takes any type of publisher as the resulting effect of filtering its updates is necessarily a vanilla
     Broadcaster.
     - Parameter sourcePublisher: The publisher whose updates are the source for the one we're building.
     - Parameter filterBlock: A block that determines whether the update should be broadcast or not. If it returns
     true, the update will be sent to its subscribers. If false, it will be ignored.
     */
    public init<PublisherType>(withSource sourcePublisher: PublisherType, filterBlock: @escaping (Update) -> Bool) where PublisherType: Publisher, PublisherType.Update == Update {
        self.init(withSubscribeBlock: { (updateBlock: @escaping UpdateBlock) in
            return sourcePublisher.subscribe({ (update) in
                if filterBlock(update) {
                    updateBlock(update)
                }
            })
        })
    }
}
