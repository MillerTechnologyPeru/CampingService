//
//  Symbols.swift
//  CampingKit
//
//  Created by Alsey Coleman Miller on 8/25/23.
//

import Foundation
import CampingService
import SwiftUI
import SFSafeSymbols

public extension Amenity {
    
    var symbol: SFSymbol {
        switch self {
        case .water:
            return .dropFill
        case .amp30:
            return .powerplug
        case .amp50:
            return .powerplug
        case .wifi:
            return .wifi
        case .laundry:
            return .washerFill
        case .mail:
            return .mail
        case .dumpStation:
            return .pipeAndDrop
        case .picnicArea:
            if #available(iOS 16.1, *) {
                return .tree
            } else {
                return .leaf
            }
        case .storage:
            return .doorGarageClosed
        case .cabins:
            return .house
        case .showers:
            return .showerFill
        case .restrooms:
            return .toiletFill
        case .pool:
            return .figurePoolSwim
        case .fishing:
            return .figureFishing
        case .beach:
            return .beachUmbrella
        case .lake:
            return .waterWaves
        case .river:
            return .waterWaves
        case .rv:
            return .bus
        case .tent:
            if #available(iOS 16.1, *) {
                return .tent2
            } else {
                return .tent
            }
        case .pets:
            return .pawprint
        }
    }
}
