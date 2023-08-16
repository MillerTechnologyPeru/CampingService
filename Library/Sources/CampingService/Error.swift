//
//  NetworkingError.swift
//  
//
//  Created by Alsey Coleman Miller on 8/15/23.
//

import Foundation

/// Camping REST API Error
public enum CampingError: Error {
    
    case authenticationRequired
    case invalidStatusCode(Int)
    case invalidResponse(Data)
}
