//
//  CreateCampgroundMigration.swift
//  
//
//  Created by Alsey Coleman Miller on 8/16/23.
//

import Foundation
import Vapor
import Fluent
import CampingService

struct CreateCampgroundMigration: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema(CampgroundModel.schema)
            .id()
            .field(CampgroundModel.DatabaseKey.name.field, .string, .required)
            .field(CampgroundModel.DatabaseKey.address.field, .string, .required)
            .field(CampgroundModel.DatabaseKey.latitude.field, .double, .required)
            .field(CampgroundModel.DatabaseKey.longitude.field, .double, .required)
            .field(CampgroundModel.DatabaseKey.amenities.field, .array(of: .array(of: .enum(Amenity.model))))
            .field(CampgroundModel.DatabaseKey.phoneNumber.field, .string)
            .field(CampgroundModel.DatabaseKey.descriptionText.field, .string, .required)
            .field(CampgroundModel.DatabaseKey.timeZone.field, .int8, .required)
            .field(CampgroundModel.DatabaseKey.notes.field, .string)
            .field(CampgroundModel.DatabaseKey.directions.field, .string)
            .field(CampgroundModel.DatabaseKey.officeHoursStart.field, .int64)
            .field(CampgroundModel.DatabaseKey.officeHoursEnd.field, .int64)
            .field(CampgroundModel.DatabaseKey.units.field, .array(of: .uuid), .references(RentalUnitModel.schema, "id"))
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(CampgroundModel.schema).delete()
    }
}
