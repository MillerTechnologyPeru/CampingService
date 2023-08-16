//
//  Reservation.swift
//  
//
//  Created by Alsey Coleman Miller on 8/16/23.
//

import Foundation

/// Reservation
public struct Reservation: Equatable, Hashable, Codable, Identifiable {
    
    public let id: UUID
    
    public let created: Date
    
    public let start: Date
    
    public let end: Date
    
    public let user: User.ID
    
    public let unit: RentalUnit.ID
    
    public var status: Status
}

public extension Reservation {
    
    enum Status: String, Codable, CaseIterable {
        
        case reserved
        case cancelled
    }
}
