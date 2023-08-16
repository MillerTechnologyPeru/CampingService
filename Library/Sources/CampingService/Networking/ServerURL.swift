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
