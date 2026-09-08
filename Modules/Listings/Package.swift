// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Listings",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "ListingsFeature", targets: ["ListingsFeature"]),
        .library(name: "ListingsAPI", targets: ["ListingsAPI"]),
    ],
    dependencies: [
        .package(path: "../Shared/TestSupport"),
    ],
    targets: [
        .target(name: "ListingsFeature"),
        .target(name: "ListingsAPI", dependencies: ["ListingsFeature"]),
        .testTarget(
            name: "ListingsAPITests",
            dependencies: ["ListingsAPI", "TestSupport"],
            resources: [.copy("Fixtures")]
        ),
    ],
    swiftLanguageModes: [.v6]
)
