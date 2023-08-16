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
    
    public init(
        id: UUID = UUID(),
        created: Date = Date(),
        start: Date,
        end: Date,
        user: User.ID,
        unit: RentalUnit.ID,
        status: Reservation.Status = .reserved
    ) {
        self.id = id
        self.created = created
        self.start = start
        self.end = end
        self.user = user
        self.unit = unit
        self.status = status
    }
}

public extension Reservation {
    
    enum Status: String, Codable, CaseIterable {
        
        case reserved
        case cancelled
    }
}
