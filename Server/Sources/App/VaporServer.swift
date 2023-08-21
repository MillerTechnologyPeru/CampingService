//
//  VaporServer.swift
//  
//
//  Created by Alsey Coleman Miller on 8/20/23.
//

import Foundation
import Vapor
import CoreModel
import NetworkObjects

extension Vapor.Application: NetworkObjectsServer {
    
    public typealias Request = Vapor.Request
    
    public typealias Response = Vapor.Response
            
    public func register<T: VaporEntityRequestController>(_ controller: T) throws {
        try self.register(collection: controller)
    }
}

public protocol VaporEntityRequestController: RouteCollection, NetworkEntityController where Self.Server == Vapor.Application, Entity: AsyncResponseEncodable { }

public extension VaporEntityRequestController {
    
    func boot(routes: RoutesBuilder) throws {
        let groupName = Self.Entity.entityName.rawValue.lowercased()
        let routeGroup = routes.grouped("\(groupName)")
        routeGroup.post(use: create)
        routeGroup.group(":id") { model in
            model.get(use: fetch)
            model.put(use: edit)
            model.delete(use: delete)
        }
    }
}

internal extension VaporEntityRequestController {
    
    func create(_ request: Server.Request) async throws -> Entity {
        let createValue = try request.content.decode(Entity.CreateView.self)
        return try await create(createValue, request: request)
    }
    
    func fetch(_ request: Request) async throws -> Entity {
        guard let id = request.parameters.get("id").flatMap({ Entity.ID(objectID: ObjectID(rawValue: $0)) }) else {
            throw Abort(.notFound)
        }
        guard let value = try await fetch(id, request: request) else {
            throw Abort(.notFound)
        }
        return value
    }
    
    func edit(_ request: Request) async throws -> Entity {
        guard let id = request.parameters.get("id").flatMap({ Entity.ID(objectID: ObjectID(rawValue: $0)) }) else {
            throw Abort(.notFound)
        }
        let editValue = try request.content.decode(Entity.EditView.self)
        return try await edit(editValue, for: id, request: request)
    }
    
    func delete(_ request: Request) async throws -> HTTPStatus {
        guard let id = request.parameters.get("id").flatMap({ Entity.ID(objectID: ObjectID(rawValue: $0)) }) else {
            throw Abort(.notFound)
        }
        guard try await delete(id, request: request) else {
            return .notFound
        }
        return .noContent
    }
}
