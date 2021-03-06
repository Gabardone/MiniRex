//
//  Task+JSONParsing.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 7/9/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


/**
 A typealias for JSON parsing tasks to make usage less onerous.
 */
public typealias JSONParsingTask<Decoded> = Task<Never, Decoded, Error> where Decoded: Decodable


/**
 A task extension to parse JSON from the calling Data.
 */
public extension Data {

    /**
     Builds a task for parsing JSON data.

     The data must contain the JSON string (i.e. needs to be uncompressed first). It will attempt to decode it using
     the usual JSONDecoder and return, if successful, the expected type.
     - Parameter queue: The queue where the task will be managed. Note that the actual work happens elsewhere.
     */
    func jsonParsingTask<T>(inQueue queue: DispatchQueue, type: T.Type) -> JSONParsingTask<T> where T: Decodable {
        return JSONParsingTask<T>(inQueue: queue, withDiscreteTaskBlock: { (completionBlock: @escaping (JSONParsingTask<T>.TaskResult) -> Void) in
            let jsonDecodingTask = {
                let jsonDecoder = JSONDecoder()
                completionBlock(JSONParsingTask<T>.TaskResult(catching: {
                    return try jsonDecoder.decode(type, from: self)
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
