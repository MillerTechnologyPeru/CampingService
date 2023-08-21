//
//  Model.swift
//  
//
//  Created by Alsey Coleman Miller on 8/20/23.
//

import Foundation
import CoreModel

public extension Model {
    
    /// Camping Service Model
    static var camping: Model {
        Model(entities: Campground.self, RentalUnit.self)
    }
}
