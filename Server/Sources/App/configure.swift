import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import CampingService

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(configuration: SQLPostgresConfiguration(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    // migrations
    app.migrations.add(CreateCampgroundMigration())
    app.migrations.add(CreateRentalUnitMigration())
    
    // configure JSON encoder
    ContentConfiguration.global.use(encoder: JSONEncoder.camping, for: .json)
    ContentConfiguration.global.use(decoder: JSONDecoder.camping, for: .json)
    
    // register routes
    try routes(app)
}
