// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Settings",
    defaultLocalization: "en",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
        .library(name: "SettingsPersistence", targets: ["SettingsPersistence"]),
        .library(name: "SettingsPresentation", targets: ["SettingsPresentation"]),
        .library(name: "SettingsTestSupport", targets: ["SettingsTestSupport"]),
    ],
    dependencies: [
        .package(path: "../Shared/SharedPresentation"),
        .package(path: "../Shared/TestSupport"),
    ],
    targets: [
        .target(name: "SettingsFeature"),
        .target(name: "SettingsPersistence", dependencies: ["SettingsFeature"]),
        .testTarget(
            name: "SettingsPersistenceTests",
            dependencies: ["SettingsPersistence", "SettingsTestSupport", "TestSupport"]
        ),
        .target(
            name: "SettingsPresentation",
            dependencies: ["SettingsFeature", "SharedPresentation"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "SettingsPresentationTests",
            dependencies: ["SettingsPresentation", "SettingsTestSupport", "TestSupport"]
        ),
        .target(name: "SettingsTestSupport", dependencies: ["SettingsFeature"]),
    ],
    swiftLanguageModes: [.v6]
)
