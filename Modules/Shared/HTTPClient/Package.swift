// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HTTPClient",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "HTTPClient", targets: ["HTTPClient"]),
        .library(name: "HTTPClientLive", targets: ["HTTPClientLive"]),
    ],
    dependencies: [
        .package(path: "../TestSupport"),
    ],
    targets: [
        .target(name: "HTTPClient"),
        .target(name: "HTTPClientLive", dependencies: ["HTTPClient"]),
        .testTarget(name: "HTTPClientLiveTests", dependencies: ["HTTPClientLive", "TestSupport"]),
    ],
    swiftLanguageModes: [.v6]
)
