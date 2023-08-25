//
//  ContentView.swift
//  CampingApp
//
//  Created by Alsey Coleman Miller on 8/15/23.
//

import SwiftUI
import CampingKit

struct ContentView: View {
    
    var body: some View {
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
