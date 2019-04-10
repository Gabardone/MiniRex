//
//  Broadcaster.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 4/9/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


/**
 A broadcaster just broadcasts updates to its subscribers. There is no specific limitation to what those may be or
 when they happen, but subscribing to them by itself should have no side effects.

 Examples include notifications and triggered repeating timers.
 */
public typealias Broadcaster<Update> = Publisher<Update>
