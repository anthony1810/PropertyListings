import SwiftUI

public enum DSColor {
    public static let names = ["surface", "surfaceElevated", "textPrimary", "textSecondary", "accent", "like"]

    public static var surface: Color { DSTokens.color("surface") }
    public static var surfaceElevated: Color { DSTokens.color("surfaceElevated") }
    public static var textPrimary: Color { DSTokens.color("textPrimary") }
    public static var textSecondary: Color { DSTokens.color("textSecondary") }
    public static var accent: Color { DSTokens.color("accent") }
    public static var like: Color { DSTokens.color("like") }
    public static let onImage = Color.white
}

public enum DSSpacing {
    public static let xs: CGFloat = 4
    public static let s: CGFloat = 8
    public static let m: CGFloat = 16
    public static let l: CGFloat = 24
    public static let xl: CGFloat = 32
}

public struct DSRadii: Equatable, Sendable {
    public static let designSystem = DSRadii(m: 12, l: 20)

    public let m: CGFloat
    public let l: CGFloat

    public init(m: CGFloat, l: CGFloat) {
        self.m = m
        self.l = l
    }
}

public enum DSRadius {
    public static var m: CGFloat { DSTokens.radii.m }
    public static var l: CGFloat { DSTokens.radii.l }
}

public struct DSTypeface: Equatable, Sendable {
    public let regular: String
    public let semibold: String
    public let bold: String

    public init(regular: String, semibold: String, bold: String) {
        self.regular = regular
        self.semibold = semibold
        self.bold = bold
    }

    func name(for weight: Font.Weight) -> String {
        switch weight {
        case .bold: bold
        case .semibold: semibold
        default: regular
        }
    }
}

public enum DSFont {
    public enum Role: Sendable {
        case largeTitle, title, price, caption

        public var style: Font.TextStyle {
            switch self {
            case .largeTitle: .largeTitle
            case .title: .headline
            case .price: .subheadline
            case .caption: .footnote
            }
        }

        public var weight: Font.Weight {
            switch self {
            case .largeTitle: .bold
            case .title: .semibold
            case .price: .bold
            case .caption: .regular
            }
        }

        public var size: CGFloat {
            switch self {
            case .largeTitle: 34
            case .title: 17
            case .price: 15
            case .caption: 13
            }
        }
    }

    public static var title: Font { font(for: .title) }
    public static var price: Font { font(for: .price) }
    public static var caption: Font { font(for: .caption) }

    static func font(for role: Role) -> Font {
        guard let typeface = DSTokens.typeface else {
            return .system(role.style, weight: role.weight)
        }
        return .custom(typeface.name(for: role.weight), size: role.size, relativeTo: role.style)
    }
}
