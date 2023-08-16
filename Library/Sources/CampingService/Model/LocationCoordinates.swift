//
//  LocationCoordinates.swift
//  
//
//  Created by Alsey Coleman Miller on 8/16/23.
//

import Foundation

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
