//
//  StoreNetworking.swift
//  
//
//  Created by Alsey Coleman Miller on 8/15/23.
//

import Foundation
import CoreModel
import NetworkObjects
import CampingService

internal extension Store {
    
    func loadURLSession() -> URLSession {
        URLSession(configuration: .ephemeral)
    }
}

private extension Store {
    
    func authorizationToken() async throws -> AuthorizationToken {
        guard let user = self.username,
            let token = self[token: user] else {
            self.username = nil
            try await self.tokenKeychain.removeAll()
            throw NetworkObjectsError.authenticationRequired
        }
        return token
    }
}

internal extension Store {
    
    func refreshAuthorizationToken() async throws {
        guard let username = self.username else {
            throw NetworkObjectsError.authenticationRequired
        }
        // remove invalid token
        await setToken(nil, for: username)
        guard let password = self[password: username] else {
            throw NetworkObjectsError.authenticationRequired
        }
        // login again for new token
        try await login(username: username, password: password)
    }
}

public extension Store {
    
    func login(
        username: String,
        password: String
    ) async throws {/*
        let token = try await urlSession.login(
            username: username,
            password: password,
            server: server
        )
        // store username in preferences and token and password in keychain
        await self.setToken(token, for: username)
        await self.setPassword(password, for: username)
        self.username = username
        #if os(iOS) && canImport(WatchConnection)
        await self.sendUsernameToWatch()
        #endif*/
    }
    
}

// MARK: - ObjectStore

extension Store: ObjectStore {
    
    public func fetch<T: NetworkEntity>(_ type: T.Type, for id: T.ID) async throws -> T {
        let value = try await networkObjects.fetch(type, for: id)
        try await commit { context in
            let modelData = try value.encode()
            try context.insert(modelData)
        }
        return value
    }
    
    public func create<T: NetworkEntity>(_ value: T.CreateView) async throws -> T {
        let newValue = try await networkObjects.create(value) as T
        try await commit { context in
            let modelData = try newValue.encode()
            try context.insert(modelData)
        }
        return newValue
    }
    
    public func edit<T: NetworkEntity>(_ value: T.EditView, for id: T.ID) async throws -> T {
        let newValue = try await networkObjects.edit(value, for: id) as T
        try await commit { context in
            let modelData = try newValue.encode()
            try context.insert(modelData)
        }
        return newValue
    }
    
    public func delete<T: NetworkEntity>(_ type: T.Type, for id: T.ID) async throws {
        try await networkObjects.delete(type, for: id)
        try await commit { context in
            try context.delete(type.entityName, for: ObjectID(id))
        }
    }
    
    public func query<T: NetworkEntity>(_ request: QueryRequest<T>) async throws -> [T.ID] {
        try await networkObjects.query(request)
    }
}
