//
//  Publisher+Filter.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 4/24/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


extension Publisher {

    /**
     Builds a Publisher that filters another publisher's updates.
     - Parameter sourcePublisher: The publisher whose updates are the source for the one we're building.
     - Parameter filterBlock: A block that determines whether the update should be broadcast or not. If it returns
     true, the update will be sent to its subscribers. If false, it will be ignored.
     */
    init(withSource sourcePublisher: Publisher<Update>, filterBlock: @escaping (Update) -> Bool) {
        self.init(withSubscribeBlock: { (updateBlock: @escaping (Update) -> Void) in
            return sourcePublisher.subscribe({ (update) in
                if filterBlock(update) {
                    updateBlock(update)
                }
            })
        })
    }
}
