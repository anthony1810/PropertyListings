import SwiftUI
import Testing
@testable import DesignSystem

@Suite struct DSThemeTests {
    @Test(arguments: [DSFont.Role.largeTitle, .title, .body, .price, .caption])
    func font_isCustom_whenATypefaceIsSet(role: DSFont.Role) {
        let brandTypeface = DSTypeface(
            regular: "Brand-Regular",
            semibold: "Brand-SemiBold",
            bold: "Brand-Bold"
        )
        let theme = DSTheme(colors: .designSystem, radii: .designSystem, typeface: brandTypeface)

        #expect(
            theme.font(for: role)
                == Font.custom(
                    brandTypeface.name(for: role.weight),
                    size: role.size,
                    relativeTo: role.style
                )
        )
    }

    @Test(arguments: [DSFont.Role.largeTitle, .title, .body, .price, .caption])
    func font_isSystem_whenNoTypefaceIsSet(role: DSFont.Role) {
        let theme = DSTheme(colors: .designSystem, radii: .designSystem, typeface: nil)

        #expect(theme.font(for: role) == Font.system(role.style, weight: role.weight))
    }
}
