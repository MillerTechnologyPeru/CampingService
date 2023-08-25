//
//  CampgroundDetailView.swift
//  CampingKit
//
//  Created by Alsey Coleman Miller on 8/25/23.
//

import Foundation
import SwiftUI
import MapKit
import CampingService

public struct CampgroundDetailView: View {
    
    @EnvironmentObject
    private var store: Store
    
    @State
    var campground: Campground
    
    public init(campground: Campground) {
        self._campground = .init(initialValue: campground)
    }
    
    public var body: some View {
        ContentView(campground: campground)
        .refreshable {
            await reloadData()
        }
        .onAppear {
            Task {
                await reloadData()
            }
        }
    }
}

internal extension CampgroundDetailView {
    
    struct ContentView: View {
        
        let campground: Campground
        
        var body: some View {
            List {
                // Address
                HStack {
                    Image(systemSymbol: .map)
                        .frame(minWidth: 30)
                    NavigationLink(destination: {
                        CampgroundMapView(campground: campground)
                    }, label: {
                        Text(verbatim: campground.address)
                    })
                }
                
                // Phone Number
                if let phoneNumber = campground.phoneNumber,
                   let url = URL(string: "tel://" + phoneNumber) {
                    HStack {
                        Image(systemSymbol: .phone)
                            .frame(minWidth: 30)
                        Link(destination: url, label: {
                            Text(verbatim: phoneNumber)
                        })
                    }
                }
                
                // Office Hours
                HStack {
                    Image(systemSymbol: .clock)
                        .frame(minWidth: 30)
                    Text(verbatim: officeHours)
                }
                
                // Text
                Text(verbatim: campground.descriptionText)
                
                // Amenities
                if campground.amenities.isEmpty == false {
                    Section("Amenities") {
                        ForEach(campground.amenities, id: \.rawValue) { amenity in
                            HStack {
                                AmenityIcon(amenity: amenity)
                                    .frame(minWidth: 30)
                                Text(amenity.localizedDescription)
                            }
                        }
                    }
                }
                
                if let directions = campground.directions {
                    Section("Directions") {
                        Text(verbatim: directions)
                    }
                }
                if let notes = campground.notes {
                    Section("Notes") {
                        Text(verbatim: notes)
                    }
                }
            }
            .navigationTitle(Text(verbatim: campground.name))
        }
    }
}

internal extension CampgroundDetailView.ContentView {
    
    var officeHours: String {
        let officeHours = campground.officeHours.localizedDescription()
        return "\(officeHours.start) - \(officeHours.end)"
    }
}
    
internal extension CampgroundDetailView {
    
    func reloadData() async {
        do {
            self.campground = try await store.fetch(Campground.self, for: campground.id)
        }
        catch {
            store.logError(error, category: .networking)
        }
    }
}

#if DEBUG

struct CampgroundDetailView_Preview: PreviewProvider {
    
    static let campground = Campground(
            name: "Lake Hartwell RV Park",
            address: "14503 SC-11, Westminster, SC 29693",
            location: .init(latitude: 34.51446212994721, longitude: -83.01371101951648),
            amenities: [.water, .amp50, .amp30, .laundry, .wifi, .picnicArea, .pets],
            phoneNumber: "8649720555",
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
            CampgroundDetailView.ContentView(campground: campground)
        }
    }
}

#endif
