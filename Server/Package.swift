// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "CampingServer",
    platforms: [
       .macOS(.v13),
       .iOS(.v15)
    ],
    dependencies: [
        .package(
            path: "../Library"
        ),
        .package(
            url: "https://github.com/vapor/vapor.git",
            from: "4.77.1"
        ),
        .package(
            url: "https://github.com/PureSwift/coremodel-mongodb",
            branch: "master"
        )
    ],
    targets: [
        .executableTarget(
            name: "CampingServer",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "CampingService", package: "Library"),
                .product(name: "MongoDBModel", package: "coremodel-mongodb"),
            ],
            path: "Sources/App"
        ),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "CampingServer"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
