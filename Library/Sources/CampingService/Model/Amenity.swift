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
    case rv
    case tent
    case pets
}

// MARK: - CoreModel

extension Array: AttributeEncodable where Self.Element == Amenity  {
    
    public var attributeValue: AttributeValue {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)
        let string = String(data: data, encoding: .utf8)!
        return .string(string)
    }
}

extension Array: AttributeDecodable where Self.Element == Amenity  {
    
    public init?(attributeValue: AttributeValue) {
        guard let string = String(attributeValue: attributeValue) else {
            return nil
        }
        let data = Data(string.utf8)
        let decoder = JSONDecoder()
        guard let value = try? decoder.decode(Self.self, from: data) else {
            return nil
        }
        self = value
    }
}
