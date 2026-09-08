// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Listings",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "ListingsFeature", targets: ["ListingsFeature"]),
        .library(name: "ListingsAPI", targets: ["ListingsAPI"]),
        .library(name: "ListingsCache", targets: ["ListingsCache"]),
    ],
    dependencies: [
        .package(path: "../Shared/TestSupport"),
    ],
    targets: [
        .target(name: "ListingsFeature"),
        .testTarget(name: "ListingsFeatureTests", dependencies: ["ListingsFeature"]),
        .target(name: "ListingsAPI", dependencies: ["ListingsFeature"]),
        .target(name: "ListingsCache", dependencies: ["ListingsFeature"]),
        .testTarget(name: "ListingsCacheTests", dependencies: ["ListingsCache", "TestSupport"]),
        .testTarget(
            name: "ListingsAPITests",
            dependencies: ["ListingsAPI", "TestSupport"],
            resources: [.copy("Fixtures")]
        ),
    ],
    swiftLanguageModes: [.v6]
)
