import NIOSSL
import Vapor
import MongoSwift
import MongoDBModel
import CampingService

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    /*
    app.databases.use(.postgres(configuration: SQLPostgresConfiguration(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)
     */
    
    let connection = "mongodb://localhost:27017"
    let mongoClient = try MongoClient(connection, using: app.eventLoopGroup)
    let databaseName = Environment.get("DATABASE_NAME") ?? "camping"
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
