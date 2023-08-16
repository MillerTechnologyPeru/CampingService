//
//  EditCampgroundRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 8/16/23.
//

import Foundation

/// Edit Campground Request
public struct EditCampgroundRequest: Equatable, Hashable, EncodableCampingURLRequest, Identifiable {
    
    public static var method: HTTPMethod { .put }
    
    public func url(for server: CampingServer) -> URL {
        URL(server: server)
            .appendingPathComponent("campground")
            .appendingPathComponent(id.description)
    }
    
    public var id: Campground.ID
    
    public var content: Content
}

public extension EditCampgroundRequest {
    
    struct Content: Equatable, Hashable, Codable {
        
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
