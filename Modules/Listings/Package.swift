// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Listings",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "ListingsFeature", targets: ["ListingsFeature"]),
    ],
    targets: [
        .target(name: "ListingsFeature"),
    ],
    swiftLanguageModes: [.v6]
)
