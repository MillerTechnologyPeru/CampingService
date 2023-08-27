import Foundation
import XCTest
#if canImport(CoreLocation)
import CoreLocation
#endif
import CoreModel
@testable import CampingService

final class CampingServiceTests: XCTestCase {
    
    func testURL() {
        
        let values: [(CampingURL, String)] = [
            (.campground(Campground.ID(uuidString: "30D9213F-2C33-4C2E-839C-77038AFBD60C")!), "x-camping-service:/campground/30D9213F-2C33-4C2E-839C-77038AFBD60C"),
            (.location(Campground.ID(uuidString: "15EF5BF2-A07A-476C-BA1B-7A7A4127C806")!), "x-camping-service:/location/15EF5BF2-A07A-476C-BA1B-7A7A4127C806"),
            (.reservation(Campground.ID(uuidString: "2A0EA762-D0C2-43C7-9422-62AE464A8360")!), "x-camping-service:/reservation/2A0EA762-D0C2-43C7-9422-62AE464A8360")
        ]
        
        for (url, string) in values {
            XCTAssertEqual(CampingURL(rawValue: string), url)
            XCTAssertEqual(url.rawValue, string)
            XCTAssertEqual(url.description, string)
            XCTAssertEqual(URL(url).absoluteString, string)
        }
    }
    
    func testAmenities() throws {
        
        let amenitites = Amenity.allCases
        let expectedValue = AttributeValue.string("water,amp30,amp50,wifi,laundry,mail,rv,tent,pets,dumpStation,picnicArea,storage,cabins,showers,restrooms,pool,fishing,beach,lake,river")
        XCTAssertEqual(amenitites.attributeValue, expectedValue)
        XCTAssertEqual([Amenity](attributeValue: expectedValue), amenitites)
        XCTAssertEqual([Amenity](attributeValue: .string("")), [])
    }
    
    func testLocation() {
        
        let location = LocationCoordinates(
            latitude: -59.709701,
            longitude: 157.668416
        )
        
        let expectedValue = AttributeValue.string("-59.709701,157.668416")
        XCTAssertEqual(location.attributeValue, expectedValue)
        XCTAssertEqual(LocationCoordinates(attributeValue: expectedValue), location)
        
        #if canImport(CoreLocation)
        let coreLocationValue = CLLocationCoordinate2D(
            latitude: -59.709701,
            longitude: 157.668416
        )
        XCTAssertEqual(LocationCoordinates(coordinates: coreLocationValue), location)
        XCTAssertEqual(CLLocationCoordinate2D(location: location).latitude, coreLocationValue.latitude)
        XCTAssertEqual(CLLocationCoordinate2D(location: location).longitude, coreLocationValue.longitude)
        #endif
    }
    
    func testSchedule() {
        
        let schedudule = Schedule(start: 60 * 8, end: 60 * 16)
        
        let expectedValue = AttributeValue.string("480,960")
        XCTAssertEqual(schedudule.attributeValue, expectedValue)
        XCTAssertEqual(Schedule(attributeValue: expectedValue), schedudule)
    }
}
