import SwiftUI
import UIKit

public struct DSPalette: Equatable, Sendable {
    public static let names = [
        "surface", "surfaceElevated", "textPrimary", "textSecondary", "accent", "like",
    ]

    public static let designSystem = DSPalette(bundle: .designSystem)

    public let surface: Color
    public let surfaceElevated: Color
    public let textPrimary: Color
    public let textSecondary: Color
    public let accent: Color
    public let like: Color
    public let onImage: Color

    public init(bundle: Bundle) {
        surface = Self.color("surface", in: bundle)
        surfaceElevated = Self.color("surfaceElevated", in: bundle)
        textPrimary = Self.color("textPrimary", in: bundle)
        textSecondary = Self.color("textSecondary", in: bundle)
        accent = Self.color("accent", in: bundle)
        like = Self.color("like", in: bundle)
        onImage = .white
    }

    private static func color(_ name: String, in bundle: Bundle) -> Color {
        if UIColor(named: name, in: bundle, compatibleWith: nil) != nil {
            return Color(name, bundle: bundle)
        }
        return Color(name, bundle: .designSystem)
    }
}
