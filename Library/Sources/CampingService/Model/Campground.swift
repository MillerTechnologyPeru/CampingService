//
//  Campground.swift
//  
//
//  Created by Alsey Coleman Miller on 8/15/23.
//

import Foundation
import CoreModel
import NetworkObjects

/// Campground Location
public struct Campground: Equatable, Hashable, Codable, Identifiable {
    
    public let id: UUID
    
    public let created: Date
    
    public let updated: Date
    
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
        created: Date,
        updated: Date,
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
        self.created = created
        self.updated = updated
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
    
    public enum CodingKeys: CodingKey {
        case id
        case created
        case updated
        case name
        case address
        case location
        case amenities
        case phoneNumber
        case descriptionText
        case timeZone
        case notes
        case directions
        case units
        case officeHours
    }
}

// MARK: - NetworkObjects

extension Campground: NetworkEntity {
    
    public static var entityName: EntityName { "Campground" }
    
    public static var attributes: [CodingKeys: AttributeType] {
        [
            .name : .string,
            .created : .date,
            .updated : .date,
            .address : .string
        ]
    }
    
    public static var relationships: [CodingKeys: Relationship] {
        [
            .units : Relationship(
                id: PropertyKey(CodingKeys.units),
                type: .toMany,
                destinationEntity: "RentalUnit",
                inverseRelationship: "campground"
            )
        ]
    }
    
    public init(from model: CoreModel.ModelData) throws {
        fatalError()
    }
    
    public typealias CreateView = Content
    
    public typealias EditView = Content
    
    public struct Content: Equatable, Hashable, Codable {
        
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
        
        public var officeHours: Schedule
        
        public init(
            name: String,
            address: String,
            location: LocationCoordinates,
            amenities: [Amenity] = [],
            phoneNumber: String? = nil,
            descriptionText: String,
            notes: String? = nil,
            directions: String? = nil,
            timeZone: Int = 0,
            officeHours: Schedule
        ) {
            self.name = name
            self.address = address
            self.location = location
            self.amenities = amenities
            self.phoneNumber = phoneNumber
            self.descriptionText = descriptionText
            self.notes = notes
            self.directions = directions
            self.timeZone = timeZone
            self.officeHours = officeHours
        }
    }
}
