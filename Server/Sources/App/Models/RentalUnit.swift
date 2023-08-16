//
//  RentalUnit.swift
//  
//
//  Created by Alsey Coleman Miller on 8/16/23.
//

import Foundation
import Fluent
import Vapor
import CampingService

final class RentalUnitModel: Model, Content {
    
    typealias IDValue = UUID
    
    static let schema = "units"
    
    @ID
    var id: UUID?
    
    @Parent(key: DatabaseKey.campground.field)
    var campground: CampgroundModel
    
    @Field(key: DatabaseKey.name.field)
    var name: String
    
    @Field(key: DatabaseKey.notes.field)
    var notes: String?
    
    @Field(key: DatabaseKey.amenities.field)
    var amenities: [Amenity]
    
    @Field(key: DatabaseKey.checkin.field)
    var checkin: Int
    
    @Field(key: DatabaseKey.checkout.field)
    var checkout: Int
    
    init() { }
}

extension RentalUnitModel {
    
    enum DatabaseKey: String {
        
        case name
        case campground = "campground_id"
        case notes
        case amenities
        case checkin
        case checkout
        
        var field: FieldKey {
            .string(rawValue)
        }
    }
}

extension RentalUnitModel {
    
    convenience init(_ value: RentalUnit) {
        self.init(
            campground: value.campground,
            name: value.name,
            notes: value.notes,
            amenities: value.amenities,
            checkout: value.checkout
        )
    }
    
    convenience init(
        campground: Campground.ID,
        name: String,
        notes: String? = nil,
        amenities: [Amenity] = [],
        checkout: Schedule
    ) {
        self.init()
        self.$campground.id = campground
        self.name = name
        self.notes = notes
        self.amenities = amenities
        self.checkin = Int(checkout.start)
        self.checkout = Int(checkout.end)
    }
}

extension RentalUnit {
    
    init(fluent model: RentalUnitModel) {
        self.init(
            id: model.id!,
            campground: model.campground.id!,
            name: model.name,
            notes: model.notes,
            amenities: model.amenities,
            checkout: .init(
                start: UInt(model.checkin),
                end: UInt(model.checkout)
            )
        )
    }
}
