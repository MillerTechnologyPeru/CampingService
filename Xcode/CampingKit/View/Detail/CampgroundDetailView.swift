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
    
    @State
    var edit: Campground.EditView
    
    @State
    var error: Error?
    
    public init(campground: Campground) {
        self._state = .init(initialValue: .view(campground))
        self._edit = .init(initialValue: .init(campground))
    }
    
    public init(create campground: Campground.CreateView) {
        self._state = .init(initialValue: .create)
        self._edit = .init(initialValue: campground)
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
            case .edit:
                CampgroundEditView(campground: $edit)
                    .navigationTitle("Edit Campground")
            case .create:
                CampgroundEditView(campground: $edit)
                    .navigationTitle("Create Campground")
            }
        }
        .toolbar {
            actionButton
        }
        .alert(isPresented: showError) {
            Alert(
                title: Text("Error"),
                message: self.error.map { Text(verbatim: $0.localizedDescription) },
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

internal extension CampgroundDetailView {
    
    enum ViewState {
        case progress(LocalizedStringKey)
        case view(Campground)
        case edit(Campground.ID)
        case create
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
        let sleepTask = Task {
            try await Task.sleep(for: .seconds(1))
        }
        do {
            campground = try await store.fetch(Campground.self, for: campground.id)
            try? await sleepTask.value
            self.view(campground)
        }
        catch {
            store.logError(error, category: .networking)
            try? await sleepTask.value
            self.error = error
        }
    }
    
    func view(_ campground: Campground) {
        self.state = .view(campground)
        self.edit = .init(campground)
    }
    
    func edit(_ campground: Campground) {
        self.state = .edit(campground.id)
        self.edit = .init(campground)
    }
    
    func save(id: Campground.ID) {
        self.state = .progress("Saving...")
        let sleepTask = Task {
            try await Task.sleep(for: .seconds(2))
        }
        Task(priority: .userInitiated) {
            do {
                let newValue: Campground = try await store.edit(edit, for: id)
                try? await sleepTask.value
                self.view(newValue)
            }
            catch {
                store.logError(error, category: .networking)
                try? await sleepTask.value
                self.error = error
                self.state = .edit(id)
            }
        }
    }
    
    func create() {
        self.state = .progress("Creating...")
        let sleepTask = Task {
            try await Task.sleep(for: .seconds(2))
        }
        Task(priority: .userInitiated) {
            do {
                let newValue: Campground = try await store.create(edit)
                try? await sleepTask.value
                self.view(newValue)
            }
            catch {
                store.logError(error, category: .networking)
                try? await sleepTask.value
                self.error = error
                self.state = .create
            }
        }
    }
    
    var actionButton: some View {
        switch state {
        case let .view(campground):
            return Button("Edit") {
                self.edit(campground)
            }
            .disabled(false)
        case let .edit(id):
            return Button("Save") {
                self.save(id: id)
            }
            .disabled(false)
        case .create:
            return Button("Save") {
                self.create()
            }
            .disabled(false)
        case .progress:
            return Button("Save") {
                assertionFailure()
            }
            .disabled(true)
        }
    }
    
    var showError: Binding<Bool> {
        Binding(get: {
            error != nil
        }, set: {
            if $0 == false {
                self.error = nil
            }
        })
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
