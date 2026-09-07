// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SharedPresentation",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "SharedPresentation", targets: ["SharedPresentation"]),
    ],
    targets: [
        .target(name: "SharedPresentation"),
    ],
    swiftLanguageModes: [.v6]
)
