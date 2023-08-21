@testable import CampingServer
import XCTVapor

final class AppTests: XCTestCase {
    
    func testHelloWorld() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await CampingServer.configure(app)
        
        #if DEBUG
        try app.test(.GET, "hello", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, world!")
        })
        #endif
    }
}
