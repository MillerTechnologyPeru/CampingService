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
    
    @EnvironmentObject
    private var store: Store
    
    @State
    private var selection: CampingTab?
    
    @State
    private var campgroundPath = NavigationPath()
    
    var body: some View {
        TabView(selection: $selection) {
            
            // Camp Tab Item
            NavigationStack(path: $campgroundPath) {
                CampgroundsListView()
            }
            .tabItem {
                Text("Camps")
                Image(systemSymbol: selection == .campgrounds ? .tentFill : .tent)
            }
            .tag(CampingTab.campgrounds)
            
            // Map Tab Item
            MapView()
            .tabItem {
                Text("Map")
                Image(systemSymbol: selection == .map ? .mapFill : .map)
            }
            .tag(CampingTab.map)
            
            // Settings
            NavigationView {
                Image(systemSymbol: .gear)
            }
            .tabItem {
                Text("Settings")
                Image(systemSymbol: selection == .map ? .gearshapeFill : .gearshape)
            }
            .tag(CampingTab.settings)
        }
        .onOpenURL(perform: openURL)
    }
}

enum CampingTab: Int, CaseIterable {
    
    case campgrounds
    case map
    case settings
}

internal extension CampingTabView {
    
    func openURL(_ url: URL) {
        guard let campingURL = CampingURL(url: url) else {
            store.log("Invalid URL \(url)", level: .error, category: .app)
            return
        }
        Task(priority: .userInitiated) {
            do {
                try await openURL(campingURL)
            }
            catch {
                store.logError(error, category: .app)
            }
        }
    }
    
    func openURL(_ campingURL: CampingURL) async throws {
        switch campingURL {
        case let .campground(id):
            let campground: Campground
            if let cache = try await store.persistentContainer.fetch(Campground.self, for: id) {
                campground = cache
            } else {
                campground = try await store.fetch(Campground.self, for: id)
            }
            self.selection = .campgrounds
            self.campgroundPath = NavigationPath([CampingNavigationItem.campground(campground)])
        case let .location(id):
            self.selection = .map
        case let .reservation(id):
            // TODO: Reservation
            self.selection = .campgrounds
        }
    }
}

#if DEBUG
struct CampingTabView_Previews: PreviewProvider {
    static var previews: some View {
        CampingTabView()
            .environmentObject(Store.preview)
    }
}
#endif
