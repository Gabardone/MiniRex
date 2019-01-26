//
//  NotificationPublisher.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 1/11/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


extension Publisher where Update == Notification {

    /**
     Builds a Publication that publishes a notification.

     The Publication has more or less the same semantics as NotificationCenter's block-based API, just like it has the
     same parameters. Use a transformer publication if you know what kind data is going to be included in the incoming
     notification and wish to deal with it in a cleaner way.
     - Parameter notificationCenter: The notification center to whose notification we wish to subscribe. Normally
     NotificationCenter.default
     - Parameter name: The name of the notification. If nil, publishes for all notifications for that match the object
     parameter irrespective of their name (or all notifications whatsoever if both parameters are nil).
     - Parameter object: The notification object whose notifications we wish to publish. If nil will publish for all
     notifications that match the name parameter irrespective of their object (or all notifications whatsoever if
     both parameters are nil).
     - Parameter queue: The queue to which notifications will be dispatched. The publisher will ostensibly publish
     them to the same queue, although a queue adapter may be used to further redirect the update calls.
     */

    fileprivate init(withNotificationCenter notificationCenter: NotificationCenter, name: Notification.Name?, object: Any?, queue: OperationQueue?) {
        self.init { (updateBlock) -> Subscription in
            //  The NotificationCenter block-based API does most of what we want 'as is'
            let notificationObserver = notificationCenter.addObserver(forName: name, object: object, queue: queue) { (notification) in
                updateBlock(notification)
            }

            //  Unsubscriber just removes from notification center. Safe against deallocations of object or other
            //  related data.
            return Subscription(withUnsubscriber: {
                //  Explicitly removing the observer.
                notificationCenter.removeObserver(notificationObserver)
            })
        }
    }
}


/**
 An extension to NotificationCenter to provide an adapter for the Publisher API.
 */
extension NotificationCenter {

    /**
     Returns a publisher for the given notification parameters.
     - Parameter name: The notification name for the publisher. If nil the publisher will update its subscribers for all
     notifications regardless of their name (but still accounting for the object parameter).
     - Parameter object: The notification object for the publisher. If nil the publisher will update its subscribers for
     all notifications regardless of their object (but still accounting for the name parameter).
     - Parameter queue: If specified, subscription updates will happen in the given queue. If nil they will happen
     in whichever queue posts the notification.
     - Returns: A Publisher for notifications of the given name and object values, targeting the given queue, that can
     be subscribed to.
     */
    public func publisher(forName name: NSNotification.Name?, object: Any?, queue: OperationQueue? = nil) -> Publisher<Notification> {
        return Publisher(withNotificationCenter: self, name: name, object: object, queue: queue)
    }

    /**
     Returns a subscription for the given notification parameters.

     This is equivalent to calling publisher(forName:object:queue:) with the same parameters and then subscribing to the
     return Publisher.
     - Parameter name: The notification name for the publisher. If nil the publisher will update its subscribers for all
     notifications regardless of their name (but still accounting for the object parameter).
     - Parameter object: The notification object for the publisher. If nil the publisher will update its subscribers for
     all notifications regardless of their object (but still accounting for the name parameter).
     - Parameter queue: If specified, subscription updates will happen in the given queue. If nil they will happen
     in whichever queue posts the notification.
     - Parameter update: The update block to be called whenever a notification matching the name and object parameters
     is posted.
     - Returns: A Subscription to notifications of the given name and object values, targeting the given queue.
     */
    public func subscribe(forName name: NSNotification.Name?, object: Any?, queue: OperationQueue?, updateBlock: @escaping (Notification) -> ()) -> Subscription {
        let publisher = self.publisher(forName: name, object: object, queue: queue)
        return publisher.subscribe(updateBlock)
    }
}
