//
//  CreateRentalUnitMigration.swift
//  
//
//  Created by Alsey Coleman Miller on 8/16/23.
//

import Foundation
import Vapor
import Fluent
import CampingService

struct CreateRentalUnitMigration: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema(RentalUnitModel.schema)
            .id()
            .field(RentalUnitModel.DatabaseKey.campground.field, .uuid, .references(CampgroundModel.schema, "id"))
            .field(RentalUnitModel.DatabaseKey.name.field, .string, .required)
            .field(RentalUnitModel.DatabaseKey.notes.field, .string)
            .field(RentalUnitModel.DatabaseKey.checkin.field, .int32, .required)
            .field(RentalUnitModel.DatabaseKey.checkout.field, .int32, .required)
            .field(RentalUnitModel.DatabaseKey.amenities.field, .array(of: .array(of: .enum(Amenity.model))))
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(RentalUnitModel.schema).delete()
    }
}
