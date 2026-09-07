// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SharedPresentation",
    defaultLocalization: "en",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "SharedPresentation", targets: ["SharedPresentation"]),
    ],
    dependencies: [
        .package(path: "../TestSupport"),
    ],
    targets: [
        .target(
            name: "SharedPresentation",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "SharedPresentationTests",
            dependencies: ["SharedPresentation", "TestSupport"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
