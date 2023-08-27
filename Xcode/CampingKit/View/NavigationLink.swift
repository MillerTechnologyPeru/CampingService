//
//  NavigationLink.swift
//  CampingKit
//
//  Created by Alsey Coleman Miller on 8/26/23.
//

import Foundation
import SwiftUI
import CampingService

/// Camping Navigation Item
public enum CampingNavigationItem: Equatable, Hashable, Codable {
    
    case campground(Campground)
}

public struct CampingNavigationLink <Label: View>: View {
    
    let value: CampingNavigationItem
    
    let label: Label
    
    public init(value: CampingNavigationItem, label: () -> (Label)) {
        self.value = value
        self.label = label()
    }
    
    public var body: some View {
        NavigationLink(value: value, label: { label })
    }
}

public struct CampingItemDetailView: View {
    
    let value: CampingNavigationItem
    
    public init(value: CampingNavigationItem) {
        self.value = value
    }
    
    public var body: some View {
        switch value {
        case .campground(let campground):
            CampgroundDetailView(campground: campground)
        }
    }
}
