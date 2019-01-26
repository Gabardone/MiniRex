//
//  Logging.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 2/7/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation
import os


extension OSLog {

    public static let miniRex = OSLog(subsystem: "org.omv.MiniRex", category: "MiniRex")
}
