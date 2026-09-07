#if canImport(UIKit)
import SnapshotTesting
import SwiftUI
import UIKit

public extension ViewImageConfig {
    @MainActor static var iPhone17: ViewImageConfig {
        .init(
            safeArea: .init(top: 62, left: 0, bottom: 34, right: 0),
            size: .init(width: 402, height: 874),
            traits: .iPhone17
        )
    }

    @MainActor static func iPhone17(_ style: UIUserInterfaceStyle) -> ViewImageConfig {
        let base = ViewImageConfig.iPhone17
        return .init(
            safeArea: base.safeArea,
            size: base.size,
            traits: base.traits.modifyingTraits { $0.userInterfaceStyle = style }
        )
    }
}

extension UITraitCollection {
    @MainActor static var iPhone17: UITraitCollection {
        UITraitCollection { traits in
            traits.layoutDirection = .leftToRight
            traits.preferredContentSizeCategory = .medium
            traits.userInterfaceIdiom = .phone
            traits.displayScale = 3
            traits.horizontalSizeClass = .compact
            traits.verticalSizeClass = .regular
        }
    }
}

public enum SnapshotHost {
    public static var isRecording: Bool {
        ProcessInfo.processInfo.environment["SNAPSHOT_RECORD"] == "1"
    }
}

public extension UIUserInterfaceStyle {
    var snapshotName: String { self == .dark ? "dark" : "light" }
}
#endif
