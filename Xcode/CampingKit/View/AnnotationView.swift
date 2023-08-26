//
//  CampgroundAnnotationView.swift
//  CampingKit
//
//  Created by Alsey Coleman Miller on 8/25/23.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation
import CampingService

struct CampgroundAnnotationView: View {
    
    @State
    private var showTitle = true
  
    let campground: Campground
  
    var body: some View {
    VStack(spacing: 0) {
        Text(verbatim: campground.name)
        .font(.callout)
        .padding(5)
        .background(Color.white)
        .foregroundColor(Color.black)
        .cornerRadius(10)
        .opacity(showTitle ? 1 : 0)
      
      Image(systemName: "mappin.circle.fill")
        .font(.title)
        .foregroundColor(.red)
      
      Image(systemName: "arrowtriangle.down.fill")
        .font(.caption)
        .foregroundColor(.red)
        .offset(x: 0, y: -5)
    }
    .onTapGesture {
      withAnimation(.easeInOut) {
        showTitle.toggle()
      }
    }
  }
}
