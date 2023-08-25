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
    
    public var body: some View {
        EntityQueryListView(
            data: loadCachedData(),
            store: store,
            cache: loadEntity,
            query: "",
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
