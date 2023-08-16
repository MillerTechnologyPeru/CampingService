//
//  Campground.swift
//  
//
//  Created by Alsey Coleman Miller on 8/15/23.
//

import Foundation

/// Campground Location
public struct Campground: Equatable, Hashable, Codable, Identifiable {
    
    public let id: UUID
    
    public var name: String
    
    public var address: String
    
    public var location: LocationCoordinates
    
    public var amenities: [Amenity]
    
    public var phoneNumber: String?
    
    public var descriptionText: String
    
    /// The number of seconds from GMT.
    public var timeZone: Int
    
    public var notes: String?
    
    public var directions: String?
    
    public var units: [RentalUnit.ID]
    
    public var officeHours: Schedule
    
    public init(
        id: UUID = UUID(),
        name: String,
        address: String,
        location: LocationCoordinates,
        amenities: [Amenity] = [],
        phoneNumber: String? = nil,
        descriptionText: String,
        notes: String? = nil,
        directions: String? = nil,
        units: [RentalUnit.ID] = [],
        timeZone: Int = 0,
        officeHours: Schedule
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.location = location
        self.amenities = amenities
        self.phoneNumber = phoneNumber
        self.descriptionText = descriptionText
        self.notes = notes
        self.directions = directions
        self.units = units
        self.timeZone = timeZone
        self.officeHours = officeHours
    }
}

