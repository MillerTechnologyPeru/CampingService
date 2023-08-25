//
//  CampgroundsListView.swift
//  CampingKit
//
//  Created by Alsey Coleman Miller on 8/24/23.
//

import Foundation
import SwiftUI
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
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(20)
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
                Text(verbatim: campground.name)
            },
            rowPlaceholder: { id in
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(20)
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
        []
    }
    
    func loadEntity(_ id: Campground.ID) -> Campground? {
        return nil
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
