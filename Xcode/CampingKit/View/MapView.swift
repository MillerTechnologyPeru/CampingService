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
    
    @State
    private var region: MKCoordinateRegion
    
    @State
    private var userTrackingMode: MapUserTrackingMode = .none
    
    @State
    private var task: Task<Void, Never>?
    
    let locationManager = AsyncLocationManager(desiredAccuracy: .hundredMetersAccuracy)
    
    public init(campground: Campground? = nil) {
        let coordinates = campground.flatMap { CLLocationCoordinate2D(location: $0.location) } ?? CLLocationCoordinate2D(latitude: 39.999733, longitude: -98.678503)
        self._region = .init(
            initialValue: MKCoordinateRegion(
                center: coordinates,
                span: MKCoordinateSpan(
                    latitudeDelta: 15,
                    longitudeDelta: 16
                )
            )
        )
    }
    
    public var body: some View {
        ContentView(
            campgrounds: campgrounds,
            region: $region,
            userTrackingMode: $userTrackingMode
        )
        .onAppear {
            // load data from server
            task?.cancel()
            task = Task(priority: .userInitiated) {
                await reloadData()
            }
            // fetch user location
            Task {
                await requestUserLocation()
            }
        }
    }
}

internal extension MapView {
    
    var campgrounds: [Campground] {
        guard store.didLoadPersistentStores else {
            return []
        }
        let fetchRequest = CoreModel.FetchRequest(entity: Campground.entityName)
        do {
            let data = try store.managedObjectContext.fetch(fetchRequest)
            return data.compactMap { try? Campground(from: $0) }
        }
        catch {
            store.logError(error, category: .persistence)
            assertionFailure(error.localizedDescription)
            return []
        }
    }
    
    @MainActor
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
    }
    
    @MainActor
    func requestUserLocation() async {
        let permission = await locationManager.requestPermission(with: .whenInUsage)
        guard permission == .authorizedWhenInUse else {
            return
        }
        self.userTrackingMode = .follow
        if let currentLocation = try? await locationManager.requestLocation() {
            
        }
    }
}

internal extension MapView {
    
    struct ContentView: View {
        
        let campgrounds: [Campground]
        
        @Binding
        private var region: MKCoordinateRegion
        
        @Binding
        private var userTrackingMode: MapUserTrackingMode
        
        init(
            campgrounds: [Campground],
            region: Binding<MKCoordinateRegion>,
            userTrackingMode: Binding<MapUserTrackingMode>
        ) {
            self.campgrounds = campgrounds
            self._region = region
            self._userTrackingMode = userTrackingMode
        }
        
        var body: some View {
            Map(
                coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: true,
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

struct MapView_Preview: PreviewProvider {
    
    static var previews: some View {
        TabView {
            NavigationView {
                MapView()
            }
            .tabItem {
                Text("Map")
                Image(systemSymbol: .map)
            }
        }
        .environmentObject(Store.preview)
    }
}

#endif
