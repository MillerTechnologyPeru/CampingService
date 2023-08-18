// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "CampingService",
    platforms: [
        .macOS(.v13),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "CampingService",
            targets: ["CampingService"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/colemancda/NetworkObjects.git",
            branch: "master"
        )
    ],
    targets: [
        .target(
            name: "CampingService",
            dependencies: [
                .product(name: "NetworkObjects", package: "NetworkObjects")
            ]
        ),
        .testTarget(
            name: "CampingServiceTests",
            dependencies: ["CampingService"]
        ),
    ]
)
