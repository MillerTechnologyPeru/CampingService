//
//  LocationCoordinates.swift
//  
//
//  Created by Alsey Coleman Miller on 8/16/23.
//

import Foundation
import CoreModel

/// Location Coordinates
public struct LocationCoordinates: Equatable, Hashable, Codable {
    
    /// Latitude
    public var latitude: Double
    
    /// Longitude
    public var longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - CoreModel

extension LocationCoordinates: AttributeEncodable {
    
    public var attributeValue: AttributeValue {
        return .string("\(latitude),\(longitude)")
    }
}

extension LocationCoordinates: AttributeDecodable {
    
    public init?(attributeValue: AttributeValue) {
        guard let string = String(attributeValue: attributeValue) else {
            return nil
        }
        let components = string.components(separatedBy: ",")
        guard components.count == 2,
            let latitude = Double(components[0]),
            let longitude = Double(components[1]) else {
            return nil
        }
        self.init(latitude: latitude, longitude: longitude)
    }
}

// MARK: - CoreLocation

#if canImport(CoreLocation)
import struct CoreLocation.CLLocationCoordinate2D

public extension LocationCoordinates {
    
    init(coordinates: CLLocationCoordinate2D) {
        self.init(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
}

public extension CLLocationCoordinate2D {
    
    init(location: LocationCoordinates) {
        self.init(latitude: location.latitude, longitude: location.longitude)
    }
}
#endif
