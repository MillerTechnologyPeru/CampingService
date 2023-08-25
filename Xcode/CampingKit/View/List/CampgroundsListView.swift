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
    
    public init() { }
    
    public var body: some View {
        EntityQueryListView(
            data: loadCachedData(),
            store: store,
            cache: loadEntity,
            query: $query,
            sort: .name,
            ascending: true,
            limit: 0,
            loadingContent: {
                VStack(alignment: .center, spacing: 8) {
                    Text("Loading")
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding(20)
                }
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
        .navigationTitle("Campgrounds")
    }
}

private extension CampgroundsListView {
    
    func loadCachedData() -> [Campground.ID] {
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
