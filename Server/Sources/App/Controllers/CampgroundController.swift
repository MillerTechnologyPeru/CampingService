//
//  CampgroundController.swift
//  
//
//  Created by Alsey Coleman Miller on 8/16/23.
//

import Foundation
import Fluent
import Vapor
import CampingService

struct CampgroundController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let campgrounds = routes.grouped("campground")
        campgrounds.get(use: index)
        //campgrounds.put(use: edit)
        campgrounds.post(use: create)
        campgrounds.group(":campgroundID") { model in
            model.delete(use: delete)
        }
    }
    
    func index(req: Request) async throws -> [Campground] {
        try await CampgroundModel
            .query(on: req.db)
            .all()
            .map { Campground(fluent: $0) }
    }
    
    func create(req: Request) async throws -> Campground {
        let request = try req.content.decode(CreateCampgroundRequest.Content.self)
        let newModel = CampgroundModel(
            name: request.name,
            address: request.address,
            location: request.location,
            amenities: request.amenities,
            phoneNumber: request.phoneNumber,
            descriptionText: request.descriptionText,
            notes: request.notes,
            directions: request.directions,
            timeZone: request.timeZone,
            officeHours: request.officeHours
        )
        try await newModel.save(on: req.db)
        let response = Campground(fluent: newModel)
        return response
    }
    /*
    func edit(req: Request) async throws -> Campground {
        let request = try req.content.decode(EditCampgroundRequest.Content.self)
        let newModel = CampgroundModel(
            name: request.name,
            address: request.address,
            location: request.location,
            amenities: request.amenities,
            phoneNumber: request.phoneNumber,
            descriptionText: request.descriptionText,
            notes: request.notes,
            directions: request.directions,
            timeZone: request.timeZone,
            officeHours: request.officeHours
        )
        try await newModel.save(on: req.db)
        let response = Campground(fluent: newModel)
        return response
    }
    */
    func delete(req: Request) async throws -> HTTPStatus {
        guard let model = try await CampgroundModel.find(req.parameters.get("campgroundID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await model.delete(on: req.db)
        return .noContent
    }
}
