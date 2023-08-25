//
//  AmenityIcon.swift
//  CampingKit
//
//  Created by Alsey Coleman Miller on 8/25/23.
//

import Foundation
import SwiftUI
import CampingService
import SFSafeSymbols

/// Amenity Icon
public struct AmenityIcon: View {
    
    let amenity: Amenity
    
    public init(amenity: Amenity) {
        self.amenity = amenity
    }
    
    public var body: some View {
        Image(systemSymbol: amenity.symbol)
            .foregroundColor(foregroundColor)
    }
}

public extension AmenityIcon {
    
    var foregroundColor: Color {
        switch amenity {
        case .water:
            return .blue
        case .amp30:
            return .yellow
        case .amp50:
            return .orange
        case .wifi:
            return .blue
        case .laundry:
            return .secondary
        case .mail:
            return .primary
        case .dumpStation:
            return .primary
        case .picnicArea:
            return .green
        case .storage:
            return .secondary
        case .cabins:
            return .brown
        case .showers:
            return .primary
        case .restrooms:
            return .secondary
        case .pool:
            return .blue
        case .fishing:
            return .green
        case .beach:
            return .yellow
        case .lake:
            return .blue
        case .river:
            return .blue
        case .rv:
            return .secondary
        case .tent:
            return .green
        case .pets:
            return .brown
        }
    }
}

#if DEBUG

struct AmenityIcon_Preview: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            List {
                ForEach(Amenity.allCases, id: \.rawValue) { amenity in
                    HStack {
                        AmenityIcon(amenity: amenity)
                            .frame(width: 30)
                        Text(amenity.localizedDescription)
                    }
                }
            }
            .navigationTitle("Amenities")
        }
        .environmentObject(Store.preview)
    }
}

#endif
