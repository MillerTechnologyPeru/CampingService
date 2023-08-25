//
//  LocalizedString.swift
//  CampingKit
//
//  Created by Alsey Coleman Miller on 8/25/23.
//

import Foundation
import SwiftUI
import CampingService

public extension Amenity {
    
    var localizedDescription: LocalizedStringResource {
        switch self {
        case .water:
            return "Water"
        case .amp30:
            return "30 Amp Power"
        case .amp50:
            return "50 Amp Power"
        case .wifi:
            return "WiFi"
        case .laundry:
            return "Laundry Room"
        case .mail:
            return "Mailbox"
        case .dumpStation:
            return "Dump Station"
        case .picnicArea:
            return "Picnic Area"
        case .storage:
            return "Storage"
        case .cabins:
            return "Cabins"
        case .showers:
            return "Public Showers"
        case .restrooms:
            return "Public Restrooms"
        case .pool:
            return "Pool"
        case .fishing:
            return "Near Fishing Spot"
        case .beach:
            return "Near Beach"
        case .lake:
            return "Near Lake"
        case .river:
            return "Near River"
        case .rv:
            return "RV Camping"
        case .tent:
            return "Tent Camping"
        case .pets:
            return "Pets Allowed"
        }
    }
}
