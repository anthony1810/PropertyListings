// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DesignSystem",
    defaultLocalization: "en",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher", from: "8.12.0"),
        .package(path: "../TestSupport"),
    ],
    targets: [
        .target(
            name: "DesignSystem",
            dependencies: [.product(name: "Kingfisher", package: "Kingfisher")],
            resources: [.process("Resources")]
        ),
        .testTarget(name: "DesignSystemTests", dependencies: ["DesignSystem", "TestSupport"]),
    ],
    swiftLanguageModes: [.v6]
)
