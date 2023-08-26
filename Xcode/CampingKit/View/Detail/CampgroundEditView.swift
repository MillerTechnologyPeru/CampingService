//
//  CampgroundEditView.swift
//  CampingKit
//
//  Created by Alsey Coleman Miller on 8/25/23.
//

import Foundation
import SwiftUI
import MapKit
import CampingService
import AsyncLocationKit

public struct CampgroundEditView: View {
    
    @EnvironmentObject
    private var store: Store
    
    @State
    var campground: Campground.Content
    
    public init(campground: Campground.Content) {
        self._campground = .init(initialValue: campground)
    }
    
    public var body: some View {
        ContentView(campground: $campground)
    }
}

internal extension CampgroundEditView {
    
    struct ContentView: View {
        
        @Binding
        var campground: Campground.Content
        
        let locationManager = AsyncLocationManager(desiredAccuracy: .hundredMetersAccuracy)
        
        var body: some View {
            List {
                
                Section {
                    TextField("Name", text: $campground.name)
                    TextField("Address", text: $campground.address)
                    TextField("Image URL", text: image)
                    TextField("Phone Number", text: phoneNumber)
                    TextField("Email", text: email)
                    TextField("Description", text: $campground.descriptionText, axis: .vertical)
                    TextField("Notes", text: notes, axis: .vertical)
                    TextField("Directions", text: directions, axis: .vertical)
                } header: {
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
                }
                                
                Section {
                    
                } header: {
                    Text("Schedule")
                }
                
                Section {
                    
                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                        center: .init(location: campground.location),
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.1,
                            longitudeDelta: 0.1
                        )
                    )), annotationItems: [CampgroundEditView.Annotation(campground: campground)], annotationContent: { annotation in
                        MapAnnotation(coordinate: .init(location: annotation.id), content: {
                            CampgroundEditView.AnnotationView(annotation: annotation)
                        })
                    })
                    .frame(minHeight: 150)
                    
                    Button("Set Current Location") {
                        Task {
                            await setCurrentLocation()
                        }
                    }
                } header: {
                    Text("Location")
                }
                
                Section("Amenities") {
                    ForEach(Amenity.allCases, id: \.rawValue) { amenity in
                        Button(action: {
                            toggleAmenity(amenity)
                        }, label: {
                            HStack {
                                AmenityIcon(amenity: amenity)
                                    .frame(minWidth: 30)
                                Text(amenity.localizedDescription)
                                Spacer(minLength: 15)
                                if campground.amenities.contains(where: { $0 == amenity }) {
                                    Image(systemSymbol: .checkmark)
                                        .foregroundColor(.green)
                                }
                            }
                        })
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

internal extension CampgroundEditView.ContentView {
    
    var image: Binding<String> {
        .init(get: {
            campground.image?.absoluteString ?? ""
        }, set: { newValue in
            campground.image = URL(string: newValue)
        })
    }
    
    var notes: Binding<String> {
        .init(get: {
            campground.notes ?? ""
        }, set: { newValue in
            campground.notes = newValue.isEmpty ? nil : newValue
        })
    }
    
    var directions: Binding<String> {
        .init(get: {
            campground.directions ?? ""
        }, set: { newValue in
            campground.directions = newValue.isEmpty ? nil : newValue
        })
    }
    
    var email: Binding<String> {
        .init(get: {
            campground.email ?? ""
        }, set: { newValue in
            campground.email = newValue.isEmpty ? nil : newValue
        })
    }
    
    var phoneNumber: Binding<String> {
        .init(get: {
            campground.phoneNumber ?? ""
        }, set: { newValue in
            campground.phoneNumber = newValue.isEmpty ? nil : newValue
        })
    }
    
    func toggleAmenity(_ amenity: Amenity) {
        // add or remove
        if let index = self.campground.amenities.firstIndex(where: { $0 == amenity }) {
            self.campground.amenities.remove(at: index)
        } else {
            self.campground.amenities.append(amenity)
        }
        // sort
        let oldValue = self.campground.amenities
        self.campground.amenities = Amenity.allCases.filter { amenity in
            oldValue.contains(where: { $0 == amenity })
        }
    }
    
    func setCurrentLocation() async {
        let permission = await locationManager.requestPermission(with: .whenInUsage)
        guard permission == .authorizedWhenInUse else {
            return
        }
        guard case let .didUpdateLocations(locations: locations) = try? await locationManager.requestLocation(),
              let location = locations.first else {
            return
        }
        self.campground.location = .init(coordinates: location.coordinate)
    }
}

internal extension CampgroundEditView {
    
    struct Annotation: Equatable, Hashable, Identifiable {
        
        let id: LocationCoordinates
        
        let name: String
        
        init(id: LocationCoordinates, name: String) {
            self.id = id
            self.name = name
        }
        
        init(campground: Campground.EditView) {
            self.id = campground.location
            self.name = campground.name
        }
    }
    
    
    struct AnnotationView: View {
        
        @State
        private var showTitle = true
      
        let annotation: Annotation
        
        var body: some View {
        VStack(spacing: 0) {
            Text(verbatim: annotation.name)
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

}

#if DEBUG

struct CampgroundEditView_Preview: PreviewProvider {
    
    struct PreviewView: View {
        
        @State
        var campground = Campground.EditView(
            name: "New Campground",
            address: "",
            location: .init(latitude: 0, longitude: 0),
            amenities: [.water, .amp30, .rv],
            descriptionText: "",
            officeHours: Schedule(start: 60 * 8, end: 60 * 18)
        )
        
        var body: some View {
            CampgroundEditView.ContentView(campground: $campground)
        }
    }
        
    static var previews: some View {
        NavigationView {
            PreviewView()
        }
    }
}

#endif

