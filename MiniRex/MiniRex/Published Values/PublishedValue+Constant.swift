//
//  PublishedValue+Constant.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 2/8/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


extension PublishedValue {

    /**
     Builds a Publisher that just updates subscribers once with a specific value.

     Technically acts as a PublishedValue but can be used as a stub for any other type of Publisher too.
     - Parameter constant: The value that will be sent to subscribers when they subscribe.
     - Note: Reference types will be retained by the Publisher.

     This is useful for testing task stubs as well as implementing protocols where a specific published value happens to
     be a constant for the implementation.
     */
    public init(withConstant constant: Update) {
        self.init(withSubscribeBlock: { (updateBlock: @escaping (Update) -> Void) in
            updateBlock(constant)

            //  Just return a dummy subscription.
            return Subscription.empty
        })
    }
}
