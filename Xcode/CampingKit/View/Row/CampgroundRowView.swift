//
//  CampgroundRowView.swift
//  CampingKit
//
//  Created by Alsey Coleman Miller on 8/25/23.
//

import Foundation
import SwiftUI
import CampingService

public struct CampgroundRowView: View {
    
    public let campground: Campground
    
    public init(campground: Campground) {
        self.campground = campground
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: campground.name)
                .font(.title3)
            Text(verbatim: campground.address.replacingOccurrences(of: "\n", with: " "))
                .font(.subheadline)
                .foregroundColor(.gray)
            if campground.amenities.isEmpty == false {
                HStack(alignment: .center, spacing: 8) {
                    ForEach(campground.amenities.prefix(8), id: \.rawValue) { amenity in
                        AmenityIcon(amenity: amenity)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }
}

#if DEBUG

struct CampgroundRowView_Preview: PreviewProvider {
    
    static let campgrounds = [
        Campground(
            name: "Fair Play RV Park",
            address: "243 Fisher Cove Rd, Fair Play, SC",
            location: .init(latitude: 34.51446212994721, longitude: -83.01371101951648),
            amenities: Amenity.allCases,
            descriptionText: """
            At Fair Play RV Park, we are committed to providing a clean, safe and fun environment for all of our guests, including your fur-babies! We look forward to meeting you and having you stay with us!
            """,
            officeHours: Schedule(start: 60 * 8, end: 60 * 18)
        ),
        Campground(
            name: "Lake Hartwell RV Park",
            address: "14503 SC-11, Westminster, SC 29693",
            location: .init(latitude: 34.51446212994721, longitude: -83.01371101951648),
            amenities: [.water, .amp50, .laundry, .wifi, .dumpStation],
            phoneNumber: "8649720555",
            descriptionText: """
            At Fair Play RV Park, we are committed to providing a clean, safe and fun environment for all of our guests, including your fur-babies! We look forward to meeting you and having you stay with us!
            """,
            officeHours: Schedule(start: 60 * 8, end: 60 * 18)
        )
    ]
    
    static var previews: some View {
        NavigationView {
            List {
                ForEach(campgrounds) { campground in
                    NavigationLink(destination: {
                        CampgroundDetailView(campground: campground)
                    }, label: {
                        CampgroundRowView(campground: campground)
                    })
                }
            }
            .navigationTitle("Campgrounds")
        }
        .environmentObject(Store.preview)
    }
}

#endif
