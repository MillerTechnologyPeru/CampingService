//
//  Amenities.swift
//  
//
//  Created by Alsey Coleman Miller on 8/16/23.
//

import Foundation
import Vapor
import Fluent
import CampingService

extension Amenity {
    
    static var model: DatabaseSchema.DataType.Enum {
        .init(name: "Amentity", cases: Amenity.allCases.map({ $0.rawValue }))
    }
}
