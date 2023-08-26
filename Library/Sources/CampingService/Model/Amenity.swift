//
//  Amenities.swift
//  
//
//  Created by Alsey Coleman Miller on 8/16/23.
//

import Foundation
import CoreModel

/// Campground Amenities
public enum Amenity: String, Codable, CaseIterable {
    
    case water
    case amp30
    case amp50
    case wifi
    case laundry
    case mail
    case rv
    case tent
    case pets
    case dumpStation
    case picnicArea
    case storage
    case cabins
    case showers
    case restrooms
    case pool
    case fishing
    case beach
    case lake
    case river
}

// MARK: - CoreModel

extension Array: AttributeEncodable where Self.Element == Amenity  {
    
    public var attributeValue: AttributeValue {
        let string = self.reduce("", { $0 + ($0.isEmpty ? "" : ",") + $1.rawValue })
        return .string(string)
    }
}

extension Array: AttributeDecodable where Self.Element == Amenity  {
    
    public init?(attributeValue: AttributeValue) {
        guard let string = String(attributeValue: attributeValue) else {
            return nil
        }
        let components = string.components(separatedBy: ",")
        var values = [Amenity]()
        values.reserveCapacity(components.count)
        for element in components {
            guard let value = Self.Element(rawValue: element) else {
                return nil
            }
            values.append(value)
        }
        self = values
    }
}
