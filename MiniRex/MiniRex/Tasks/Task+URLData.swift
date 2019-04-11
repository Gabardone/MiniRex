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
     - Returns: A task that downloads the contents of the URL into a Data. It will start executing as soon as a
     subscriber is added.
     */
    public static func urlDataTask(forURL url: URL, inQueue queue: DispatchQueue) -> Task<Data, Error> {
        //  Declared here so it can bridge task execution and cancel.
        var urlDataTask: URLSessionDataTask? = nil

        return Task<Data, Error>(inQueue: queue, withTaskBlock: { (completion) in
            urlDataTask = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
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
}
