//
//  CreateCampgroundRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 8/16/23.
//

import Foundation

/// Create Campground Request
public struct CreateCampgroundRequest: Equatable, Hashable, EncodableCampingURLRequest {
    
    public static var method: HTTPMethod { .post }
    
    public func url(for server: CampingServer) -> URL {
        URL(server: server)
            .appendingPathComponent("campground")
    }
    
    public var content: Content
}

public extension CreateCampgroundRequest {
    
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
