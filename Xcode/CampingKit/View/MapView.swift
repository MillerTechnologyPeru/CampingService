//
//  MapView.swift
//  CampingKit
//
//  Created by Alsey Coleman Miller on 8/25/23.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation
import CoreData
import CoreModel
import CoreDataModel
import CampingService
import AsyncLocationKit

public struct MapView: View {
    
    @EnvironmentObject
    private var store: Store
    
    @Binding
    private var region: MKCoordinateRegion
    
    @State
    private var userTrackingMode: MapUserTrackingMode = .none
    
    @State
    private var showsUserLocation = false
    
    @State
    private var task: Task<Void, Never>?
    
    @State
    private var didAppear = false
    
    @State
    private var campgrounds: [Campground] = []
    
    @State
    var error: Error?
    
    let locationManager = AsyncLocationManager(desiredAccuracy: .hundredMetersAccuracy)
    
    public init(region: Binding<MKCoordinateRegion>) {
        self._region = region
    }
    
    public var body: some View {
        ContentView(
            campgrounds: campgrounds,
            region: $region,
            userTrackingMode: $userTrackingMode,
            showsUserLocation: $showsUserLocation
        )
        .onAppear {
            fetchCache()
            // load data from server
            task?.cancel()
            task = Task(priority: .userInitiated) {
                await reloadData()
            }
            if didAppear == false {
                didAppear = true
                // fetch user location
                Task {
                    await requestUserLocation()
                }
            }
        }
        .onDisappear {
            task?.cancel()
            task = nil
        }
        .alert(isPresented: showError) {
            Alert(
                title: Text("Error"),
                message: self.error.map { Text(verbatim: $0.localizedDescription) },
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

internal extension MapView {
    
    func fetchCache() {
        guard store.didLoadPersistentStores else {
            return
        }
        let fetchRequest = CoreModel.FetchRequest(entity: Campground.entityName)
        do {
            let data = try store.managedObjectContext.fetch(fetchRequest)
            let cache = data.compactMap { try? Campground(from: $0) }
            self.campgrounds = cache
        }
        catch {
            store.logError(error, category: .persistence)
            assertionFailure(error.localizedDescription)
        }
    }
    
    func reloadData() async {
        let request = QueryRequest<Campground>()
        let objectIDs: [Campground.ID]
        do {
            objectIDs = try await store.query(request)
        }
        catch {
            store.logError(error, category: .networking)
            return
        }
        // load each if not cached
        let tasks = objectIDs.map { id in
            Task(priority: .background) {
                guard (try? await store.persistentContainer.fetch(Campground.self, for: id)) == nil else {
                    return
                }
                do {
                    _ = try await store.fetch(Campground.self, for: id)
                }
                catch {
                    store.logError(error, category: .networking)
                }
            }
        }
        // wait for all tasks
        for task in tasks {
            await task.value
        }
        // update local campgrounds
        fetchCache()
    }
    
    @MainActor
    func requestUserLocation() async {
        let permission = await locationManager.requestPermission(with: .whenInUsage)
        guard permission == .authorizedWhenInUse else {
            return
        }
        self.userTrackingMode = .none
        self.showsUserLocation = true
        if let currentLocation = try? await locationManager.requestLocation(),
           case let .didUpdateLocations(locations: locations) = currentLocation,
            let location = locations.first {
            self.region.center = location.coordinate
            self.region.span = .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        }
    }
    
    var showError: Binding<Bool> {
        Binding(get: {
            error != nil
        }, set: {
            if $0 == false {
                self.error = nil
            }
        })
    }
}

internal extension MapView {
    
    struct ContentView: View {
        
        let campgrounds: [Campground]
        
        @Binding
        private var region: MKCoordinateRegion
        
        @Binding
        private var userTrackingMode: MapUserTrackingMode
        
        @Binding
        private var showsUserLocation: Bool
        
        init(
            campgrounds: [Campground],
            region: Binding<MKCoordinateRegion>,
            userTrackingMode: Binding<MapUserTrackingMode>,
            showsUserLocation: Binding<Bool>
        ) {
            self.campgrounds = campgrounds
            self._region = region
            self._userTrackingMode = userTrackingMode
            self._showsUserLocation = showsUserLocation
        }
        
        var body: some View {
            Map(
                coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: showsUserLocation,
                userTrackingMode: $userTrackingMode,
                annotationItems: campgrounds) { campground in
                    MapAnnotation(coordinate: .init(location: campground.location)) {
                        CampgroundAnnotationView(campground: campground)
                    }
                }
        }
    }
}

#if DEBUG
/*
struct MapView_Preview: PreviewProvider {
    
    static var previews: some View {
        TabView {
            NavigationView {
                MapView(region: )
            }
            .tabItem {
                Text("Map")
                Image(systemSymbol: .map)
            }
        }
        .environmentObject(Store.preview)
    }
}
*/
#endif
