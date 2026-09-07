// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HTTPClient",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "HTTPClient", targets: ["HTTPClient"]),
    ],
    targets: [
        .target(name: "HTTPClient"),
    ],
    swiftLanguageModes: [.v6]
)
