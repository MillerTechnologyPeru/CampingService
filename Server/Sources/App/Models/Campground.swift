//
//  Campground.swift
//  
//
//  Created by Alsey Coleman Miller on 8/16/23.
//

import Foundation
import Fluent
import Vapor
import CampingService

final class CampgroundModel: Model, Content {
    
    typealias IDValue = UUID
    
    static let schema = "campgrounds"
    
    @ID
    var id: UUID?
    
    @Field(key: DatabaseKey.name.field)
    var name: String
    
    @Field(key: DatabaseKey.address.field)
    var address: String
    
    @Field(key: DatabaseKey.latitude.field)
    var latitude: Double
    
    @Field(key: DatabaseKey.longitude.field)
    var longitude: Double
    
    @Field(key: DatabaseKey.amenities.field)
    var amenities: [Amenity]
    
    @Field(key: DatabaseKey.phoneNumber.field)
    var phoneNumber: String?
    
    @Field(key: DatabaseKey.descriptionText.field)
    var descriptionText: String
    
    @Field(key: DatabaseKey.timeZone.field)
    public var timeZone: Int
    
    @Field(key: DatabaseKey.notes.field)
    public var notes: String?
    
    @Field(key: DatabaseKey.directions.field)
    public var directions: String?
    
    @Field(key: DatabaseKey.officeHoursStart.field)
    public var officeHoursStart: Int
    
    @Field(key: DatabaseKey.officeHoursEnd.field)
    public var officeHoursEnd: Int
    
    @Children(for: \.$campground)
    public var units: [RentalUnitModel]
    
    init() { }
}

extension CampgroundModel {
    
    enum DatabaseKey: String {
        
        case name
        case address
        case latitude
        case longitude
        case amenities
        case phoneNumber
        case descriptionText
        case timeZone
        case notes
        case directions
        case officeHoursStart
        case officeHoursEnd
        case units
        
        var field: FieldKey {
            .string(rawValue)
        }
    }
}

extension CampgroundModel {
    
    convenience init(
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
        self.init()
        self.name = name
        self.address = address
        self.latitude = location.latitude
        self.longitude = location.longitude
        self.amenities = amenities
        self.phoneNumber = phoneNumber
        self.descriptionText = descriptionText
        self.notes = notes
        self.directions = directions
        self.timeZone = timeZone
        self.officeHoursStart = Int(officeHours.start)
        self.officeHoursEnd = Int(officeHours.end)
    }
}