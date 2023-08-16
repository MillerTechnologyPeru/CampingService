// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "CampingServer",
    platforms: [
       .macOS(.v13),
       .iOS(.v15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.77.1"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
        // ὁ8 Fluent driver for Postgres.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.7.2"),
        // Shared Code
        .package(path: "../Library")
    ],
    targets: [
        .executableTarget(
            name: "CampingServer",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "CampingService", package: "Library")
            ],
            path: "Sources/App"
        ),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "CampingServer"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
