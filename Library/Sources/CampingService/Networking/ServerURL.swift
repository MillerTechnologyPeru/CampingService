//
//  ServerURL.swift
//  
//
//  Created by Alsey Coleman Miller on 8/15/23.
//

import Foundation

/// Camping Server URL
public struct CampingServer: Codable, Equatable, Hashable, Sendable {
    
    internal let url: URL
    
    internal init(url: URL) {
        self.url = url
    }
}

public extension URL {
    
    init(server: CampingServer) {
        self = server.url
    }
}

// MARK: - RawRepresentable

extension CampingServer: RawRepresentable {
    
    public init?(rawValue: String) {
        guard let url = URL(string: rawValue) else {
            return nil
        }
        self.init(url: url)
    }
    
    public var rawValue: String {
        url.absoluteString
    }
}

// MARK: - CustomStringConvertible

extension CampingServer: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        rawValue
    }
    
    public var debugDescription: String {
        rawValue
    }
}

// MARK: - Definitions

public extension CampingServer {
    
    static func localhost(port: UInt = 8080) -> CampingServer {
        return CampingServer(rawValue: "http://localhost:" + port.description)!
    }
}

// MARK: - Supporting Types

public enum CampingEntity: String, Codable, CaseIterable {
    
    case campground
    case rentalUnit = "unit"
    case reservation
    case device
    case user
}

public enum CampingURI {
    
    case fetch(CampingEntity, UUID)
    case search(CampingEntity, String, sort: [String], order: [String])
    case create(CampingEntity)
    case edit(CampingEntity, UUID)
    case delete(CampingEntity, UUID)
}

public extension CampingURI {
    
    var entity: CampingEntity {
        switch self {
        case .fetch(let entity, _):
            return entity
        case .search(let entity, _, _, _):
            return entity
        case .create(let entity):
            return entity
        case .edit(let entity, _):
            return entity
        case .delete(let entity, _):
            return entity
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetch:
            return .get
        case .search:
            return .get
        case .create:
            return .post
        case .edit:
            return .put
        case .delete:
            return .delete
        }
    }
    
    func url(for server: CampingServer) -> URL {
        var url = URL(server: server)
        switch self {
        case .fetch(let entity, let id):
            return url
                .appendingPathComponent(entity.rawValue)
                .appendingPathComponent(id.description)
        case .search(let entity, let searchString, let sort, let order):
            url
                .appendPathComponent(entity.rawValue)
            if searchString.isEmpty == false {
                url.append(queryItems: [URLQueryItem(name: "search", value: searchString)])
            }
            // TODO: Sort and Order
            return url
        case .create(let entity):
            return url
                .appendingPathComponent(entity.rawValue)
        case .edit(let entity, let id):
            return url
                .appendingPathComponent(entity.rawValue)
                .appendingPathComponent(id.description)
        case .delete(let entity, let id):
            return url
                .appendingPathComponent(entity.rawValue)
                .appendingPathComponent(id.description)
        }
    }
}
