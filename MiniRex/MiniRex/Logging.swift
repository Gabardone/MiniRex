//
//  Logging.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 2/7/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation
import os


@available(iOS 10, macOS 10.12, tvOS 10, watchOS 3,  *)
extension OSLog {
    public static let miniRex = OSLog(subsystem: "org.omv.MiniRex", category: "MiniRex")
}
