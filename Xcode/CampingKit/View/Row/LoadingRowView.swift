//
//  LoadingRowView.swift
//  CampingKit
//
//  Created by Alsey Coleman Miller on 8/25/23.
//

import Foundation
import SwiftUI

public struct LoadingRowView: View {
    
    public init() { }
    
    public var body: some View {
        HStack {
            ProgressView()
                .progressViewStyle(.circular)
                .padding(20)
            Text("Loading...")
        }
    }
}

#if DEBUG

struct LoadingRowView_Preview: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            List {
                LoadingRowView()
                LoadingRowView()
            }
            .navigationTitle("Campgrounds")
        }
    }
}

#endif
