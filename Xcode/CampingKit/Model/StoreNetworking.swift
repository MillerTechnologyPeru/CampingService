//
//  StoreNetworking.swift
//  
//
//  Created by Alsey Coleman Miller on 8/15/23.
//

import Foundation
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
    /*
    func authorized<T>(
        _ block: (AuthorizationToken) async throws -> T
    ) async throws -> T {
        // refresh token if logged in but missing token
        if let username = self.username, self[token: username] == nil {
            try await refreshAuthorizationToken()
        }
        let token = try await authorizationToken()
        do {
            return try await block(token)
        }
        catch {
            if let networkError = error as? CampingError,
                case .invalidStatusCode(401, _) = networkError {
                try await refreshAuthorizationToken()
                // retry once
                let token = try await authorizationToken()
                return try await block(token)
            } else {
                throw error
            }
        }
    }*/
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
