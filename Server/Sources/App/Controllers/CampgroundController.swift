//
//  CampgroundController.swift
//  
//
//  Created by Alsey Coleman Miller on 8/16/23.
//

import Foundation
import Vapor
import CoreModel
import NetworkObjects
import CampingService
import MongoSwift
import MongoDBModel

struct CampgroundController: VaporEntityController {
    
    let database: MongoModelStorage
    
    func create(
        _ newValue: Campground.CreateView,
        request: Vapor.Request
    ) async throws -> Campground {
        let campground = Campground(
            name: newValue.name,
            image: newValue.image,
            address: newValue.address,
            location: newValue.location,
            amenities: newValue.amenities,
            phoneNumber: newValue.phoneNumber,
            email: newValue.email,
            descriptionText: newValue.descriptionText,
            notes: newValue.notes,
            directions: newValue.directions,
            timeZone: newValue.timeZone,
            officeHours: newValue.officeHours
        )
        try await database.insert(campground)
        return campground
    }
    
    func edit(
        _ newValue: Campground.EditView,
        for id: Campground.ID,
        request: Vapor.Request
    ) async throws -> Campground {
        // fetch existing
        guard var campground = try await database.fetch(Campground.self, for: id) else {
            throw Abort(.notFound)
        }
        // apply changes
        campground.updated = Date()
        campground.name = newValue.name
        campground.image = newValue.image
        campground.address = newValue.address
        campground.location = newValue.location
        campground.amenities = newValue.amenities
        campground.phoneNumber = newValue.phoneNumber
        campground.email = newValue.email
        campground.descriptionText = newValue.descriptionText
        campground.notes = newValue.notes
        campground.directions = newValue.directions
        campground.timeZone = newValue.timeZone
        campground.officeHours = newValue.officeHours
        // return updated value
        try await database.insert(campground)
        return campground
    }
    
    func query(_ queryRequest: QueryRequest<Campground>, request: Request) async throws -> [Campground.ID] {
        
        let fetchRequest = FetchRequest(
            entity: Campground.entityName,
            sortDescriptors: queryRequest.sort.flatMap { [FetchRequest.SortDescriptor(property: PropertyKey($0), ascending: queryRequest.ascending ?? true)] } ?? [],
            predicate: queryRequest.query.map { Campground.CodingKeys.name.stringValue.compare(.contains, .attribute(.string($0))) },
            fetchLimit: queryRequest.limit.map { Int($0) } ?? 0,
            fetchOffset: queryRequest.offset.map { Int($0) } ?? 0
        )
        let results = try await database.fetchID(fetchRequest)
        return results.map { .init(objectID: $0)! }
    }
}
