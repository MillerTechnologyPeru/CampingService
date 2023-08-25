//
//  TabView.swift
//  CampingApp
//
//  Created by Alsey Coleman Miller on 8/25/23.
//

import Foundation
import SwiftUI
import CampingKit
import SFSafeSymbols

struct CampingTabView: View {
    
    @State
    private var selection: CampingTab?
    
    var body: some View {
        TabView(selection: $selection) {
            // Camp Tab Item
            NavigationView {
                CampgroundsListView()
            }
            .tabItem {
                Text("Camp")
                Image(systemSymbol: .tent)
            }
            .tag(CampingTab.campgrounds)
            
            // Map Tab Item
            NavigationView {
                CampgroundsListView()
            }
            .tabItem {
                Text("Map")
                Image(systemSymbol: .map)
            }
            .tag(CampingTab.map)
            
            // Settings
            NavigationView {
                Image(systemSymbol: .gear)
            }
            .tabItem {
                Text("Settings")
                Image(systemSymbol: .gearshape)
            }
            .tag(CampingTab.settings)
        }
    }
}

enum CampingTab: Int, CaseIterable {
    
    case campgrounds
    case map
    case settings
}

#if DEBUG
struct CampingTabView_Previews: PreviewProvider {
    static var previews: some View {
        CampingTabView()
            .environmentObject(Store.preview)
    }
}
#endif
