// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Listings",
    defaultLocalization: "en",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "ListingsFeature", targets: ["ListingsFeature"]),
        .library(name: "ListingsAPI", targets: ["ListingsAPI"]),
        .library(name: "ListingsCache", targets: ["ListingsCache"]),
        .library(name: "ListingsPresentation", targets: ["ListingsPresentation"]),
        .library(name: "ListingsUI", targets: ["ListingsUI"]),
        .library(name: "ListingsTestSupport", targets: ["ListingsTestSupport"]),
    ],
    dependencies: [
        .package(path: "../Shared/DesignSystem"),
        .package(path: "../Shared/SharedPresentation"),
        .package(path: "../Shared/TestSupport"),
    ],
    targets: [
        .target(name: "ListingsFeature"),
        .testTarget(name: "ListingsFeatureTests", dependencies: ["ListingsFeature"]),
        .target(name: "ListingsAPI", dependencies: ["ListingsFeature"]),
        .target(name: "ListingsCache", dependencies: ["ListingsFeature"]),
        .testTarget(name: "ListingsCacheTests", dependencies: ["ListingsCache", "ListingsTestSupport", "TestSupport"]),
        .target(
            name: "ListingsPresentation",
            dependencies: ["ListingsFeature", "SharedPresentation"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "ListingsPresentationTests",
            dependencies: ["ListingsPresentation", "ListingsTestSupport", "TestSupport"]
        ),
        .target(
            name: "ListingsUI",
            dependencies: [
                "ListingsPresentation",
                .product(name: "DesignSystem", package: "DesignSystem", condition: .when(platforms: [.iOS])),
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(name: "ListingsUITests", dependencies: ["ListingsUI", "TestSupport"]),
        .target(name: "ListingsTestSupport", dependencies: ["ListingsFeature"]),
        .testTarget(
            name: "ListingsAPITests",
            dependencies: ["ListingsAPI", "ListingsTestSupport", "TestSupport"],
            resources: [.copy("Fixtures")]
        ),
    ],
    swiftLanguageModes: [.v6]
)
