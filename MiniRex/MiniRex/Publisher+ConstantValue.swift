//
//  Publisher+ConstantValue.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 2/8/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


extension Publisher {

    /**
     Builds a Publication that just updates subscribers once with a specific value.
     - Parameter constant: The value that will be sent to subscribers when they subscribe.
     - Note: Reference types will be retained by the Publisher.

     This is useful for testing stubs as well as implementing protocols where a specific published property happens to
     be a constant for the implementation.
     */
    init(withConstant constant: Update) {
        self.init(withSubscribeBlock: { (updateBlock: @escaping (Update) -> ()) in
            updateBlock(constant)

            //  Just return a dummy subscription.
            return Subscription(withUnsubscriber: {})
        })
    }
}
