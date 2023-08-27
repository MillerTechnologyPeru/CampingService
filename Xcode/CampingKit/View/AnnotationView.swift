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

public struct CampgroundAnnotationView: View {
    
    let campground: Campground
    
    @State
    private var showTitle = false
    
    public init(
        campground: Campground,
        showTitle: Bool = false
    ) {
        self.campground = campground
        self.showTitle = showTitle
    }
  
    public var body: some View {
    VStack(spacing: 6) {
        NavigationLink(destination: {
            CampgroundDetailView(campground: campground)
        }, label: {
            CampgroundRowView(campground: campground)
        })
        .padding(8)
        .background(Color.white)
        .foregroundColor(Color.black)
        .cornerRadius(10)
        .opacity(showTitle ? 1 : 0)
        
        VStack(spacing: 0) {
            Image(systemSymbol: .mappinCircleFill)
                .font(.title)
                .foregroundColor(.red)
          
            Image(systemSymbol: .arrowtriangleDownFill)
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
}

#if DEBUG
struct CampgroundAnnotationView_Preview: PreviewProvider {
    
    struct PreviewView: View {
        
        let campground: Campground
        
        @State
        private var region: MKCoordinateRegion
        
        init(campground: Campground) {
            self.campground = campground
            let region = MKCoordinateRegion(
                center: .init(location: campground.location),
                span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            self._region = .init(initialValue: region)
        }
        
        var body: some View {
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: false, userTrackingMode: .none, annotationItems: [campground], annotationContent: { campground in
                MapAnnotation(coordinate: .init(location: campground.location)) {
                    CampgroundAnnotationView(campground: campground, showTitle: true)
                }
            })
            .ignoresSafeArea()
        }
    }
    
    static let campground = Campground(
            name: "Lake Hartwell RV Park",
            image: URL(string: "https://img1.wsimg.com/isteam/ip/b093c9e9-5e8a-4308-95f9-9ed306268f26/100.JPG/:/rs=w:1968,h:1476")!,
            address: "14503 SC-11, Westminster, SC 29693",
            location: .init(latitude: 34.51446212994721, longitude: -83.01371101951648),
            amenities: [.water, .amp50, .amp30, .laundry, .wifi, .picnicArea, .pets, .rv],
            phoneNumber: "8649720555",
            email: "lkhtwlrvpark@outlook.com",
            descriptionText: """
            Our RV Park is designed with you in mind. We've focused our time and energy on keeping our site clean, safe, and fun. Our laidback atmosphere will make your visit with us as enjoyable and relaxing as possible. We hope that our park will make you want to stay with us each and every time you travel to South Carolina.
            """,
            notes: """
            Lake Hartwell RV Park is an adult only park (18 years and up) with unobstructed views of the southern skies. Satellite reception is accessible to all campers. It is a place where you can come and let your hair down in a quiet country setting. We have 22 sites that include 30/50-amp service.  Just take I-85 to Exit 1 and merge onto SC Hwy 11. Continue for 5 miles and we are on the right.  You can't miss us!  You can sit back and relax in the peace and quiet of your personal campsite, meet the neighbors, or take in some local attractions.  There are over 15 breathtaking waterfalls surrounding the area, beautiful Lake Hartwell (just down the road), and the charming town of Westminster nearby. If you're a sports enthusiast, numerous boat ramps and golf courses are just down the road.  SC Hwy 11 is known as the Cherokee Foothills Scenic Highway, which winds through upstate South Carolina.  Following the Southernmost peaks of the Blue Ridge Mountains, the route is surrounded by peach orchards, quaint villages and parks.  It is an alternative to I-85 and has been featured in such publications as: National Geographic, Rand McNally, and Southern Living.
            """,
            officeHours: Schedule(start: 60 * 8, end: 60 * 18)
    )
    
    static var previews: some View {
        NavigationView {
            PreviewView(campground: campground)
        }
        .environmentObject(Store.preview)
    }
}
#endif
