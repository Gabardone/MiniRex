//
//  Result+Covariance.swift
//  MiniRex
//
//  Created by Óscar Morales Vivó on 5/5/20.
//  Copyright © 2020 Óscar Morales Vivó. All rights reserved.
//

import Foundation


public extension Result {

    /**
     Simple utility to return a version of the given result that uses a generic Error as its failure parameter. This
     makes it easier to have some covariance for tasks that return the same or related data.
     */
    func generic() -> Result<Success, Error> {
        switch self {
        case .success(let success):
            return .success(success)

        case .failure(let error):
            return .failure(error)
        }
    }
}
