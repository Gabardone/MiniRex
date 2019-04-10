//
//  Publisher+SingleUpdate.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 4/9/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


extension Publisher {

    /**
     Subscribes to the next update of the publisher.

     Unlike a regular subscription, you can ignore the returning Subscription as it will keep itself alive until the
     update happens. It is still returned in case there's a reason to keep it around an invalidate it before it gets
     called.
     - Parameter updateBlock: Same as regular subscribe, but it will only get called once on the next update no matter
     the behavior of the Publisher.
     - Returns: The Subscription object. Feel free to ignore it unless there's a reason it may need to be invalidated
     before it receives its update.
     */
    @discardableResult
    func subscribeToSingleUpdate(_ updateBlock: @escaping (Update) -> ()) -> Subscription {
        var result: Subscription?
        result = self.subscribe { (update) in
            updateBlock(update)

            //  Make sure we don't get more.
            result?.invalidate()
            result = nil
        }

        if let result = result {
            //  Still haven't gotten our single update. Send back.
            return result
        } else {
            //  I guess the update already happened. Return an empty subscription.
            return Subscription.empty
        }
    }
}
