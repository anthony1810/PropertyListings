// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RemoteConfig",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "RemoteConfigFeature", targets: ["RemoteConfigFeature"]),
        .library(name: "RemoteConfigAPI", targets: ["RemoteConfigAPI"]),
        .library(name: "RemoteConfigCache", targets: ["RemoteConfigCache"]),
    ],
    dependencies: [
        .package(path: "../Shared/TestSupport")
    ],
    targets: [
        .target(name: "RemoteConfigFeature"),
        .target(name: "RemoteConfigAPI", dependencies: ["RemoteConfigFeature"]),
        .target(name: "RemoteConfigCache", dependencies: ["RemoteConfigFeature"]),
        .testTarget(
            name: "RemoteConfigCacheTests",
            dependencies: ["RemoteConfigCache", "TestSupport"]
        ),
        .testTarget(
            name: "RemoteConfigAPITests",
            dependencies: ["RemoteConfigAPI", "TestSupport"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
