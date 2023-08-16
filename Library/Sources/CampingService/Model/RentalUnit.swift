//
//  RentalUnit.swift
//  
//
//  Created by Alsey Coleman Miller on 8/16/23.
//

import Foundation

/// Campground Rental Unit
public struct RentalUnit: Equatable, Hashable, Codable, Identifiable {
    
    public let id: UUID
    
    public let campground: Campground.ID
    
    public var name: String
    
    public var notes: String?
    
    public var amenities: [Amenity]
    
    public var checkout: Schedule
    
    public init(
        id: UUID = UUID(),
        campground: Campground.ID,
        name: String,
        notes: String? = nil,
        amenities: [Amenity] = [],
        checkout: Schedule
    ) {
        self.id = id
        self.campground = campground
        self.name = name
        self.notes = notes
        self.amenities = amenities
        self.checkout = checkout
    }
}

