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
    targets: [
        .target(
            name: "CampingService"),
        .testTarget(
            name: "CampingServiceTests",
            dependencies: ["CampingService"]
        ),
    ]
)
