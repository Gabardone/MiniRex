//
//  Task+URLData.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 4/10/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


/**
 A simple typealias to wrap data download tasks to make logic more readable and less prone to Swift generics
 pedantry.
 */
public typealias DataDownloadTask = Task<Never, Data, URLError>


/**
 A pre-packaged task that downloads the data at the calling URL.

 Pretty common task in modern application development and take home interview work.
 */
public extension URL {

    /**
     Returns a task that downloads the at the calling URL into a Data struct if successful, returning an error if
     failing.

     This task doesn't report on progress. Use for short, small downloads or those where you don't really care about
     tracking their progress.
     - Parameter queue: The queue where the task will be managed and the results will be sent.
     - Returns: A task that downloads the data pointed at by the URL into a Data value. It will start executing as soon
     as a subscriber is added.
     */
    func downloadTask(inQueue queue: DispatchQueue) -> DataDownloadTask {
        //  Declared here so it can bridge task execution and cancel.
        var urlDataTask: URLSessionDataTask? = nil

        return DataDownloadTask(inQueue: queue, withTaskBlock: { (completion) in
            urlDataTask = URLSession.shared.dataTask(with: self) { data, response, error in
                if let error = error {
                    if let urlError = error as? URLError {
                        if urlError.code == .cancelled {
                            //  We're letting this one slide as we wouldn't expect a canceled task to update, and we're the only ones who can.
                        } else {
                            completion(.completed(withResult: .failure(urlError)))
                        }
                    } else {
                        let unknownError = URLError(.unknown, userInfo: [NSURLErrorKey: self])
                        completion(.completed(withResult: .failure(unknownError)))
                    }
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    //  TODO: We probably can come up with a better error to model this.
                    let serverError = URLError(.badServerResponse, userInfo: [NSURLErrorKey: self])
                    completion(.completed(withResult: .failure(serverError)))
                    return
                }

                guard let receivedData = data else {
                    //  If we somehow didn't get any data (even an ampty one) we return an error.
                    let dataError = URLError(.zeroByteResource, userInfo: [NSURLErrorKey: self])
                    completion(.completed(withResult: .failure(dataError)))
                    return
                }

                completion(.completed(withResult: .success(receivedData)))
            }
            urlDataTask?.resume()
        }, cancelBlock: {
            //  I guess we can cancel the download...
            urlDataTask?.cancel()
        })
    }
}


/**
 A simple typealias to wrap file read into Data tasks to make logic more readable and less prone to Swift generics
 pedantry.
 */
public typealias FileReadTask = Task<Never, Data, Error>


/**
 A pre-packaged task that reads the file pointed at by the calling URL into memory.
 */
public extension URL {

    /**
     Returns a task that reads the contents of the file at the given URL into a Data struct if successful, returning
     an error if unsuccessful.
     - Parameter queue: The queue where the task will be managed and the results will be sent.
     - Returns: A task that reads the contents of the file pointed at by the URL into a Data value. It will start
     executing as soon as a subscriber is added.
     */
    func fileReadTask(inQueue queue: DispatchQueue) -> FileReadTask {
        return Task<Never, Data, Error>(inQueue: queue, withTaskBlock: { (completion) in
            //  Dispatch the actual work to a global queue. completion will send back to the given one.
            let taskExecution = {
                completion(.completed(withResult: Result(catching: {
                    return try Data(contentsOf: self)
                })))
            }

            if #available(macOS 10.10, iOS 8, tvOS 9, watchOS 2, *) {
                //  Use a global queue with the same QoS and the task management one. Priority promotion will happen
                //  if needed.
                DispatchQueue.global(qos: queue.qos.qosClass).async(execute: taskExecution)
            } else {
                //  No QoS API, use a default global queue 🤷🏽‍♂️
                DispatchQueue.global(priority: .default).async(execute: taskExecution)
            }
        })
    }
}
