import Vapor
import MongoDBModel

func routes(_ app: Application, database: MongoModelStorage) throws {
    #if DEBUG
    debugRoutes(app)
    #endif
    
    try app.register(collection: CampgroundController(database: database))
}

private func debugRoutes(_ app: Application) {
    app.get { req async in
        "It works!"
    }
    app.get("hello") { req async -> String in
        "Hello, world!"
    }
}
