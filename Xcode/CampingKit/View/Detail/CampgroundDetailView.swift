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
    var state: ViewState
    
    public init(campground: Campground) {
        self._state = .init(initialValue: .view(campground))
    }
    
    public init(create campground: Campground.CreateView) {
        self._state = .init(initialValue: .create(campground))
    }
    
    public var body: some View {
        ZStack {
            switch state {
            case let .progress(title):
                LoadingView(title: title)
            case let .view(campground):
                ContentView(campground: campground)
                .refreshable {
                    await reloadData()
                }
                .onAppear {
                    Task {
                        await reloadData()
                    }
                }
            case let .edit(id, editValue):
                CampgroundEditView(campground: .init(get: {
                    editValue
                }, set: {
                    self.state = .edit(id, $0)
                }))
                .navigationTitle("Edit Campground")
            case let .create(createValue):
                CampgroundEditView(campground: .init(get: {
                    createValue
                }, set: {
                    self.state = .create($0)
                }))
                .navigationTitle("Create Campground")
            }
        }
        .toolbar {
            actionButton
        }
    }
}

internal extension CampgroundDetailView {
    
    enum ViewState {
        case progress(LocalizedStringKey)
        case view(Campground)
        case edit(Campground.ID, Campground.EditView)
        case create(Campground.CreateView)
    }
    
    struct LoadingView: View {
        
        let title: LocalizedStringKey
        
        var body: some View {
            VStack(alignment: .center, spacing: 8) {
                Text(title)
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(20)
            }
        }
    }
    
    struct ContentView: View {
        
        let campground: Campground
        
        var body: some View {
            List {
                
                Section(content: {
                    
                    // Address
                    HStack {
                        Image(systemSymbol: .map)
                            .frame(minWidth: 30)
                        NavigationLink(destination: {
                            MapView(campground: campground)
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
                    
                    if let email = campground.email,
                       let url = URL(string: "mailto://" + email) {
                        HStack {
                            Image(systemSymbol: .envelope)
                                .frame(minWidth: 30)
                            Link(destination: url, label: {
                                Text(verbatim: email)
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
                    
                }, header: {
                    if let url = campground.image {
                        CachedAsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .imageScale(.medium)
                                .cornerRadius(10)
                                .padding(.bottom, 15)
                        } placeholder: {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        }
                    }
                })
                
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
                
                //
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
        guard case var .view(campground) = self.state else {
            return
        }
        do {
            campground = try await store.fetch(Campground.self, for: campground.id)
            self.state = .view(campground)
        }
        catch {
            store.logError(error, category: .networking)
        }
    }
    
    func edit(_ campground: Campground) {
        let editValue = Campground.EditView(
            name: campground.name,
            image: campground.image,
            address: campground.address,
            location: campground.location,
            amenities: campground.amenities,
            phoneNumber: campground.phoneNumber,
            email: campground.email,
            descriptionText: campground.descriptionText,
            notes: campground.notes,
            directions: campground.directions,
            timeZone: campground.timeZone,
            officeHours: campground.officeHours
        )
        self.state = .edit(campground.id, editValue)
    }
    
    func save(id: Campground.ID, value: Campground.EditView) {
        self.state = .progress("Saving")
        let sleepTask = Task {
            try await Task.sleep(for: .seconds(1))
        }
        Task(priority: .userInitiated) {
            let newState: ViewState
            do {
                let newValue: Campground = try await store.edit(value, for: id)
                newState = .view(newValue)
            }
            catch {
                store.logError(error, category: .networking)
                newState = .edit(id, value)
                // TODO: Show alert
                
            }
            try? await sleepTask.value
            self.state = newState
        }
    }
    
    func create(_ newValue: Campground.CreateView) {
        self.state = .progress("Saving")
        let sleepTask = Task {
            try await Task.sleep(for: .seconds(1))
        }
        Task(priority: .userInitiated) {
            let newState: ViewState
            do {
                let newValue: Campground = try await store.create(newValue)
                newState = .view(newValue)
            }
            catch {
                store.logError(error, category: .networking)
                newState = .create(newValue)
                // TODO: Show alert
                
            }
            try? await sleepTask.value
            self.state = newState
        }
    }
    
    var actionButton: some View {
        VStack {
            switch state {
            case let .view(campground):
                Button("Edit") {
                    self.edit(campground)
                }
            case let .edit(id, editValue):
                Button("Save") {
                    self.save(id: id, value: editValue)
                }
            case let .create(newValue):
                Button("Save") {
                    self.create(newValue)
                }
            case .progress:
                EmptyView()
            }
        }
    }
}

#if DEBUG

struct CampgroundDetailView_Preview: PreviewProvider {
    
    static let campground = Campground(
            name: "Lake Hartwell RV Park",
            image: URL(string: "https://img1.wsimg.com/isteam/ip/b093c9e9-5e8a-4308-95f9-9ed306268f26/100.JPG/:/rs=w:1968,h:1476")!,
            address: "14503 SC-11, Westminster, SC 29693",
            location: .init(latitude: 34.51446212994721, longitude: -83.01371101951648),
            amenities: [.water, .amp50, .amp30, .laundry, .wifi, .picnicArea, .pets],
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
            CampgroundDetailView.ContentView(campground: campground)
        }
    }
}

#endif
