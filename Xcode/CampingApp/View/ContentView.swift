//
//  ContentView.swift
//  CampingApp
//
//  Created by Alsey Coleman Miller on 8/15/23.
//

import SwiftUI
import CampingKit
import AsyncLocationKit

struct ContentView: View {
    
    @EnvironmentObject
    private var store: Store
    
    let locationManager = AsyncLocationManager(desiredAccuracy: .hundredMetersAccuracy)
    
    var body: some View {
        content
            .onAppear {
                Task {
                    await store.loadPersistentStores()
                    let _ = await locationManager.requestPermission(with: .whenInUsage)
                }
            }
    }
    
    var content: some View {
        #if os(iOS)
        CampingTabView()
        #elseif os(tvOS)
        NavigationStack {
            CampgroundsListView()
        }
        #elseif os(macOS)
        NavigationStack {
            CampgroundsListView()
        }
        #endif
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Store.preview)
    }
}
#endif
