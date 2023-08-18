import Foundation
import XCTest
#if canImport(CoreLocation)
import CoreLocation
#endif
import CoreModel
@testable import CampingService

final class CampingServiceTests: XCTestCase {
    
    func testAmenities() throws {
        
        let amenitites = Amenity.allCases
        let expectedValue = AttributeValue.string("water,amp30,amp50,wifi,laundry,mail,dumpStation,picnicArea,storage,cabins,showers,restrooms,pool,fishing,beach,lake,river,rv,tent,pets")
        XCTAssertEqual(amenitites.attributeValue, expectedValue)
        XCTAssertEqual([Amenity](attributeValue: expectedValue), amenitites)
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
