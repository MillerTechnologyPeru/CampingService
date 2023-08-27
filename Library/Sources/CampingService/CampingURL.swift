//
//  CampingURL.swift
//  
//
//  Created by Alsey Coleman Miller on 8/26/23.
//

import Foundation

/// Camping URL
public enum CampingURL: Equatable, Hashable {
    
    /// Campground Details
    case campground(Campground.ID)
    
    /// Campground location on map
    case location(Campground.ID)
    
    /// Reservation Details
    case reservation(Reservation.ID)
}

public extension CampingURL {
    
    static var scheme: String { "x-camping-service" }
}

internal extension CampingURL {
    
    var type: URLType {
        switch self {
        case .campground: return .campground
        case .location: return .location
        case .reservation: return .reservation
        }
    }
    
    enum URLType: String {
        
        case campground
        case location
        case reservation
        
        var componentsCount: Int {
            switch self {
            case .campground:
                return 2
            case .location:
                return 2
            case .reservation:
                return 2
            }
        }
    }
}

// MARK: - RawRepresentable

extension CampingURL: RawRepresentable {
    
    public init?(rawValue: String) {
        guard let url = URL(string: rawValue) else {
            return nil
        }
        self.init(url: url)
    }
    
    public var rawValue: String {
        URL(self).absoluteString
    }
}

// MARK: - CustomStringConvertible

extension CampingURL: CustomStringConvertible {
    
    public var description: String {
        rawValue
    }
}

// MARK: - URL

public extension URL {
    
    init(_ campingURL: CampingURL) {
        let type = campingURL.type
        var path = [String]()
        path.reserveCapacity(type.componentsCount)
        path.append(type.rawValue)
        switch campingURL {
        case let .campground(id):
            path.append(id.description)
        case let .location(id):
            path.append(id.description)
        case let .reservation(id):
            path.append(id.description)
        }
        var components = URLComponents()
        components.scheme = CampingURL.scheme
        components.path = path.reduce("", { $0 + "/" + $1 })
        guard let url = components.url
            else { fatalError("Could not compose URL") }
        self = url
    }
}

public extension CampingURL {
    
    init?(url: URL) {
        
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        
        guard url.scheme == CampingURL.scheme,
              let type = pathComponents.first.flatMap({ URLType(rawValue: $0.lowercased()) }),
              pathComponents.count == type.componentsCount
        else { return nil }
        
        switch type {
        case .campground:
            guard let id = Campground.ID(uuidString: pathComponents[1]) else {
                return nil
            }
            self = .campground(id)
        case .location:
            guard let id = Campground.ID(uuidString: pathComponents[1]) else {
                return nil
            }
            self = .location(id)
        case .reservation:
            guard let id = Reservation.ID(uuidString: pathComponents[1]) else {
                return nil
            }
            self = .reservation(id)
        }
    }
}
