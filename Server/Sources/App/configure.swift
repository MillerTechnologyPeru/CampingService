import NIOSSL
import Vapor
import MongoSwift
import MongoDBModel
import CampingService

// configures your application
extension CampingServer {
    
    static func configure(_ app: Application) async throws {
        
        // configure MongoDB connection
        let hostname = Environment.get("DATABASE_HOST") ?? "localhost"
        let port = Environment.get("DATABASE_PORT").flatMap(UInt.init(_:)) ?? 27017
        let databaseName = Environment.get("DATABASE_NAME") ?? "camping"
        let connection = "mongodb://\(hostname):\(port)"
        var options = MongoClientOptions()
        if let username = Environment.get("DATABASE_USERNAME"),
           let password = Environment.get("DATABASE_PASSWORD") {
            options.credential = .init(
                username: username,
                password: password
            )
        }
        let mongoClient = try MongoClient(connection, using: app.eventLoopGroup, options: options)
        self.mongoClient = mongoClient
        let database = MongoModelStorage(
            database: mongoClient.db(databaseName),
            model: .camping
        )
        
        // configure JSON encoder
        ContentConfiguration.global.use(encoder: JSONEncoder.camping, for: .json)
        ContentConfiguration.global.use(decoder: JSONDecoder.camping, for: .json)
        
        // register routes
        try routes(app, database: database)
    }
}
