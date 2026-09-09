// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Bookmarks",
    defaultLocalization: "en",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "BookmarksFeature", targets: ["BookmarksFeature"]),
        .library(name: "BookmarksPersistence", targets: ["BookmarksPersistence"]),
        .library(name: "BookmarksPresentation", targets: ["BookmarksPresentation"]),
        .library(name: "BookmarksTestSupport", targets: ["BookmarksTestSupport"]),
    ],
    dependencies: [
        .package(path: "../Shared/SharedPresentation"),
        .package(path: "../Shared/TestSupport"),
    ],
    targets: [
        .target(name: "BookmarksFeature"),
        .target(name: "BookmarksPersistence", dependencies: ["BookmarksFeature"]),
        .testTarget(
            name: "BookmarksPersistenceTests",
            dependencies: ["BookmarksPersistence", "BookmarksTestSupport", "TestSupport"]
        ),
        .target(name: "BookmarksPresentation", dependencies: ["BookmarksFeature", "SharedPresentation"]),
        .testTarget(
            name: "BookmarksPresentationTests",
            dependencies: ["BookmarksPresentation", "BookmarksTestSupport", "TestSupport"]
        ),
        .target(name: "BookmarksTestSupport", dependencies: ["BookmarksFeature"]),
    ],
    swiftLanguageModes: [.v6]
)
