import SwiftUI

public struct DSTheme: Equatable, Sendable {
    public static let designSystem = DSTheme(
        colors: .designSystem,
        radii: .designSystem,
        typeface: nil
    )

    public let colors: DSPalette
    public let radii: DSRadii
    public let typeface: DSTypeface?

    public init(colors: DSPalette, radii: DSRadii, typeface: DSTypeface?) {
        self.colors = colors
        self.radii = radii
        self.typeface = typeface
    }

    public func font(for role: DSFont.Role) -> Font {
        guard let typeface else {
            return .system(role.style, weight: role.weight)
        }
        return .custom(typeface.name(for: role.weight), size: role.size, relativeTo: role.style)
    }
}
