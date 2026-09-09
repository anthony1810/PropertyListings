// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Bookmarks",
    defaultLocalization: "en",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "BookmarksFeature", targets: ["BookmarksFeature"]),
        .library(name: "BookmarksTestSupport", targets: ["BookmarksTestSupport"]),
    ],
    dependencies: [
        .package(path: "../Shared/TestSupport"),
    ],
    targets: [
        .target(name: "BookmarksFeature"),
        .target(name: "BookmarksTestSupport", dependencies: ["BookmarksFeature"]),
    ],
    swiftLanguageModes: [.v6]
)
