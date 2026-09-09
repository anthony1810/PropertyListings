// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TestSupport",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "TestSupport", targets: ["TestSupport"])],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.3.2"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.0"),
        .package(url: "https://github.com/pointfreeco/swift-clocks", from: "1.0.6"),
    ],
    targets: [
        .target(
            name: "TestSupport",
            dependencies: [
                .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "Clocks", package: "swift-clocks"),
            ]
        ),
        .testTarget(
            name: "TestSupportTests",
            dependencies: ["TestSupport"],
            resources: [.copy("Fixtures")]
        ),
    ],
    swiftLanguageModes: [.v6]
)
