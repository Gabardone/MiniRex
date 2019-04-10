//
//  PublishedValue.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 4/9/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


/**
 A published value offers a value of a certain type for subscription. Subscribers will get an initial update with the
 value at the time of subscription, followed by further update calls whenever it changes.

 A published value for an Equatable type will only send updates when the actual value changes per its Equatable
 implementation. A non-equatable reference type will only send updates when the identity of the value changes.

 Semantically, it can be expected that the ultimate source of the published value is a reference type and is retained
 by any subscriptions it may have.
 */
public typealias PublishedValue<ValueType> = Publisher<ValueType>
