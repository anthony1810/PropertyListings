import SwiftUI

public enum DSColor {
    public static let surface = Color("surface", bundle: .module)
    public static let surfaceElevated = Color("surfaceElevated", bundle: .module)
    public static let textPrimary = Color("textPrimary", bundle: .module)
    public static let textSecondary = Color("textSecondary", bundle: .module)
    public static let accent = Color("accent", bundle: .module)
    public static let like = Color("like", bundle: .module)
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
    public static let title = Font.system(.headline, design: .rounded, weight: .semibold)
    public static let price = Font.system(.subheadline, design: .rounded, weight: .bold)
    public static let caption = Font.system(.footnote)
}
