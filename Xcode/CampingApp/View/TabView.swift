//
//  TabView.swift
//  CampingApp
//
//  Created by Alsey Coleman Miller on 8/25/23.
//

import Foundation
import SwiftUI
import MapKit
import CampingKit
import SFSafeSymbols

struct CampingTabView: View {
    
    @EnvironmentObject
    private var store: Store
    
    @State
    private var selection: Int = 0
    
    @State
    private var campgroundPath = [CampingNavigationItem]()
    
    @State
    private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -81.034331, longitude: 34.000749),
        span: MKCoordinateSpan(
            latitudeDelta: 15,
            longitudeDelta: 15
        )
    )
    
    var body: some View {
        TabView(selection: $selection) {
            
            // Camp Tab Item
            NavigationStack(path: $campgroundPath) {
                CampgroundsListView()
            }
            .tabItem {
                Text("Camps")
                Image(systemSymbol: .tent)
            }
            .tag(CampingTab.campgrounds.rawValue)
            
            // Map Tab Item
            NavigationStack {
                MapView(region: $mapRegion)
            }
            .tabItem {
                Text("Map")
                Image(systemSymbol: .map)
            }
            .tag(CampingTab.map.rawValue)
            
            // Map Tab Item
            NavigationStack {
                Image(systemSymbol: .ticketFill)
            }
            .tabItem {
                Text("Reservation")
                Image(systemSymbol: .ticket)
            }
            .tag(CampingTab.reservations.rawValue)
            
            // Settings
            NavigationView {
                Image(systemSymbol: .gear)
            }
            .tabItem {
                Text("Settings")
                Image(systemSymbol: .gearshape)
            }
            .tag(CampingTab.settings.rawValue)
        }
        .onOpenURL(perform: openURL)
    }
}

enum CampingTab: Int, CaseIterable {
    
    case campgrounds
    case map
    case reservations
    case settings
}

internal extension CampingTabView {
    
    func show(tab: CampingTab) {
        self.selection = tab.rawValue
    }
    
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
            self.show(tab: .campgrounds)
            if self.campgroundPath != [.campground(campground)] {
                if self.campgroundPath.isEmpty == false {
                    try? await Task.sleep(for: .milliseconds(100))
                    self.campgroundPath.removeAll(keepingCapacity: true)
                    try? await Task.sleep(for: .seconds(1))
                }
                self.campgroundPath.append(.campground(campground))
            }
        case let .location(id):
            let campground: Campground
            if let cache = try await store.persistentContainer.fetch(Campground.self, for: id) {
                campground = cache
            } else {
                campground = try await store.fetch(Campground.self, for: id)
            }
            self.show(tab: .map)
            try? await Task.sleep(for: .milliseconds(500))
            self.mapRegion = .init(
                center: .init(location: campground.location),
                span: .init(
                    latitudeDelta: 0.01,
                    longitudeDelta: 0.01
                )
            )
        case let .reservation(id):
            // TODO: Reservation
            self.show(tab: .reservations)
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
