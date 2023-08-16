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
        campgrounds.post(use: create)
        campgrounds.group(":campgroundID") { model in
            model.delete(use: delete)
        }
    }
    
    func index(req: Request) async throws -> [CampgroundModel] {
        try await CampgroundModel.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> CampgroundModel {
        let todo = try req.content.decode(CampgroundModel.self)
        try await todo.save(on: req.db)
        return todo
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let model = try await CampgroundModel.find(req.parameters.get("campgroundID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await model.delete(on: req.db)
        return .noContent
    }
}
