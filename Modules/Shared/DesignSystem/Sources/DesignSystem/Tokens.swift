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

public enum DSRadius {
    public static let m: CGFloat = 12
    public static let l: CGFloat = 20
}

public enum DSFont {
    public static let title = Font.system(.headline, weight: .semibold)
    public static let price = Font.system(.subheadline, weight: .bold)
    public static let caption = Font.system(.footnote)
}
