//
//  Task+URLData.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 4/10/19.
//  Copyright © 2019 Óscar Morales Vivó. All rights reserved.
//

import Foundation


/**
 A pre-packaged task that fetches the data at the given URL.

 Pretty common task in modern application development and take home interview work.
 */
extension Task where Update == Result<Data, Error> {

    /**
     Returns a task that downloads the data at the given URL into a Data struct if successful, returning an error if
     failing.
     - Parameter url: The URL whose data we want to get.
     - Parameter queue: The queue where the task will be managed and the results will be sent.
     - Returns: A task that downloads the data pointed at by the URL into a Data value. It will start executing as soon
     as a subscriber is added.
     */
    public static func downloadTask(forURL url: URL, inQueue queue: DispatchQueue) -> Task<Data, Error> {
        //  Declared here so it can bridge task execution and cancel.
        var urlDataTask: URLSessionDataTask? = nil

        return Task<Data, Error>(inQueue: queue, withTaskBlock: { (completion) in
            urlDataTask = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    if let urlError = error as? URLError, urlError.code == .cancelled {
                        //  We're letting this one slide as we wouldn't expect a canceled task to update, and we're the only ones who can.
                    } else {
                        completion(.failure(error))
                    }
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    //  TODO: We probably can come up with a better error to model this.
                    let serverError = URLError(.badServerResponse)
                    completion(.failure(serverError))
                    return
                }

                guard let receivedData = data else {
                    let dataError = URLError(.zeroByteResource)
                    completion(.failure(dataError))
                    return
                }

                completion(.success(receivedData))
            }
            urlDataTask?.resume()
        }, cancelBlock: {
            //  I guess we can cancel the download...
            urlDataTask?.cancel()
        })
    }


    /**
     Returns a task that reads the contents of the file at the given URL into a Data struct if successful, returning an
     error if unsuccessful.
     - Parameter url: The file URL whose data we want to get. Undefined behavior if other types of URLs sent.
     - Parameter queue: The queue where the task will be managed and the results will be sent.
     - Returns: A task that reads the contents of the file pointed at by the URL into a Data value. It will start
     executing as soon as a subscriber is added.
     */
    public static func fileReadTask(forFileAtURL url: URL, inQueue queue: DispatchQueue) -> Task<Data, Error> {
        return Task<Data, Error>(inQueue: queue, withTaskBlock: { (completion) in
            //  Dispatch the actual work to a global queue. completion will send back to the given one.
            //  TODO: Use QoS once support for macOS 10.9/iOS 7 is dropped.
            DispatchQueue.global(priority: .default).async {
                do {
                    let data = try Data(contentsOf: url)
                    completion(.success(data))
                } catch (let error) {
                    completion(.failure(error))
                }
            }
        })
    }
}
