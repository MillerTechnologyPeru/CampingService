//
//  CampgroundsListView.swift
//  CampingKit
//
//  Created by Alsey Coleman Miller on 8/24/23.
//

import Foundation
import SwiftUI
import CoreModel
import NetworkObjects
import NetworkObjectsUI
import CampingService
import SFSafeSymbols

public struct CampgroundsListView: View {
    
    @EnvironmentObject
    private var store: Store
    
    @State
    var query: String = ""
    
    @State
    var newValue: Campground.CreateView?
    
    public init() { }
    
    public var body: some View {
        ZStack {
            if store.didLoadPersistentStores {
                EntityQueryListView(
                    data: loadCachedData(),
                    store: store,
                    cache: loadEntity,
                    query: $query,
                    sort: .name,
                    ascending: true,
                    limit: 0,
                    loadingContent: {
                        LoadingView()
                    },
                    emptyContent: {
                        Text("No campgrounds found.")
                    },
                    errorContent: { error in
                        VStack {
                            Image(systemSymbol: .exclamationmarkTriangle)
                            Text(verbatim: error.localizedDescription)
                            Spacer()
                            Button("Retry") {
                                reloadData()
                            }
                        }
                    },
                    rowContent: { campground in
                        NavigationLink(destination: {
                            CampgroundDetailView(campground: campground)
                        }, label: {
                            CampgroundRowView(campground: campground)
                        })
                    },
                    rowPlaceholder: { id in
                        LoadingRowView()
                    },
                    rowError: { error in
                        VStack {
                            Image(systemSymbol: .exclamationmarkTriangle)
                            Text(verbatim: error.localizedDescription)
                        }
                    }
                )
            } else {
                LoadingView()
            }
        }
        .navigationTitle("Campgrounds")
        .toolbar {
            Button(action: {
                create()
            }, label: {
                Image(systemSymbol: .plus)
            })
        }
        .sheet(isPresented: createSheet, content: {
            NavigationView {
                CampgroundDetailView(create: newValue!)
            }
        })
    }
}

internal extension CampgroundsListView {
    
    struct LoadingView: View {
        
        var body: some View {
            VStack(alignment: .center, spacing: 8) {
                Text("Loading Campgrounds")
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(20)
            }
        }
    }
}

private extension CampgroundsListView {
    
    func loadCachedData() -> [Campground.ID] {
        guard store.didLoadPersistentStores else {
            return []
        }
        let fetchRequest = CoreModel.FetchRequest(
            entity: Campground.entityName,
            sortDescriptors: [
                .init(property: PropertyKey(Campground.CodingKeys.name))
            ]
        )
        do {
            return try store.managedObjectContext.fetchID(fetchRequest)
                .compactMap { .init(objectID: $0) }
        }
        catch {
            store.logError(error, category: .persistence)
            return []
        }
    }
    
    func loadEntity(_ id: Campground.ID) -> Campground? {
        guard store.didLoadPersistentStores else {
            return nil
        }
        do {
            guard let data = try store.managedObjectContext.fetch(Campground.entityName, for: ObjectID(id)) else {
                return nil
            }
            return try Campground(from: data)
        }
        catch {
            store.logError(error, category: .persistence)
            return nil
        }
    }
    
    func reloadData() {
        
    }
    
    func create() {
        self.newValue = Campground.CreateView(
            name: "New Campground",
            image: nil,
            address: "",
            location: .init(latitude: 0, longitude: 0),
            amenities: [],
            phoneNumber: nil,
            email: nil,
            descriptionText: "",
            notes: nil,
            directions: nil,
            timeZone: 0,
            officeHours: Schedule(
                start: 60 * 8,
                end: 60 * 18
            )
        )
    }
    
    var createSheet: Binding<Bool> {
        .init(
            get: { self.newValue != nil },
            set: { self.newValue = $0 ? self.newValue : nil }
        )
    }
}

#if DEBUG

struct CampgroundsListView_Preview: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            CampgroundsListView()
        }
        .environmentObject(Store.preview)
    }
}

#endif
