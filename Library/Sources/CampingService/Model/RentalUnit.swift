//
//  RentalUnit.swift
//  
//
//  Created by Alsey Coleman Miller on 8/16/23.
//

import Foundation
import CoreModel
import NetworkObjects

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
    
    public enum CodingKeys: CodingKey {
        case id
        case campground
        case name
        case notes
        case amenities
        case checkout
    }
}

// MARK: - CoreModel

extension RentalUnit: Entity {
        
    public static var attributes: [CodingKeys: AttributeType] {
        [
            .name : .string,
            .notes : .string,
            .amenities : .string,
            .checkout : .string
        ]
    }
    
    public static var relationships: [CodingKeys: Relationship] {
        [
            .campground : Relationship(
                id: PropertyKey(CodingKeys.campground),
                type: .toOne,
                destinationEntity: Campground.entityName,
                inverseRelationship: PropertyKey(Campground.CodingKeys.units)
            )
        ]
    }
}

// MARK: - NetworkObjects

extension RentalUnit: NetworkEntity {
    
    public typealias CreateView = Content
    
    public typealias EditView = Content
    
    public struct Content: Equatable, Hashable, Codable {
        
        public var name: String
        
        public var notes: String?
        
        public var amenities: [Amenity]
        
        public var checkout: Schedule
        
        public init(name: String, notes: String? = nil, amenities: [Amenity] = [], checkout: Schedule) {
            self.name = name
            self.notes = notes
            self.amenities = amenities
            self.checkout = checkout
        }
    }
}
