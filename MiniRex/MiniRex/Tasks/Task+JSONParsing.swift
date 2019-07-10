//
//  Task+JSONParsing.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 7/9/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


/**
 A task extension to parse JSON to a given type.
 */
extension Task where Progress == Never, Success: Decodable, Failure == Error {

    /**
     Builds a task for parsing JSON data.

     The data must contain the JSON string (i.e. needs to be uncompressed first). It will attempt to decode it using
     the usual JSONDecoder and return, if successful, the expected type.
     - Parameter queue: The queue where the task will be managed. Note that the actual work happens elsewhere.
     - Parameter data: The data containing the JSON we want to parse.
     */
    func jsonParsingTask(inQueue queue: DispatchQueue, forData data: Data) -> Task {
        return Task(inQueue: queue, withDiscreteTaskBlock: { (completionBlock: @escaping (Result<Success, Failure>) -> Void) in
            let jsonDecodingTask = {
                let jsonDecoder = JSONDecoder()
                completionBlock(Result<Success, Error>(catching: {
                    return try jsonDecoder.decode(Success.self, from: data)
                }))
            }
            if #available(macOS 10.10, iOS 8, tvOS 9, watchOS 2, *) {
                DispatchQueue.global(qos: .utility).async(execute: jsonDecodingTask)
            } else {
                DispatchQueue.global(priority: .background).async(execute: jsonDecodingTask)
            }
        })
    }
}
