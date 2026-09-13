import SwiftUI
import Testing
@testable import DesignSystem

extension RegistryTests {
    @Suite final class DSThemeBridgeTests {
        init() {
            DSTokens.configure(bundle: nil)
            DSTokens.configure(radii: nil)
            DSTokens.configure(typeface: nil)
        }

        @Test func designSystemTheme_hasTheColoursTheRegistryAnswers_whenNothingIsRegistered() {
            let theme = DSTheme.designSystem

            #expect(lightHex(of: theme.colors.surface) == lightHex(of: DSColor.surface))
            #expect(
                lightHex(of: theme.colors.surfaceElevated) == lightHex(of: DSColor.surfaceElevated)
            )
            #expect(lightHex(of: theme.colors.textPrimary) == lightHex(of: DSColor.textPrimary))
            #expect(lightHex(of: theme.colors.textSecondary) == lightHex(of: DSColor.textSecondary))
            #expect(lightHex(of: theme.colors.accent) == lightHex(of: DSColor.accent))
            #expect(lightHex(of: theme.colors.like) == lightHex(of: DSColor.like))
            #expect(lightHex(of: theme.colors.onImage) == lightHex(of: DSColor.onImage))
        }

        @Test func designSystemTheme_hasTheRadiiTheRegistryAnswers_whenNothingIsRegistered() {
            let theme = DSTheme.designSystem

            #expect(theme.radii.m == DSRadius.m)
            #expect(theme.radii.l == DSRadius.l)
        }

        @Test(arguments: [DSFont.Role.largeTitle, .title, .price, .caption])
        func designSystemTheme_hasTheFontsTheRegistryAnswers_whenNothingIsRegistered(
            role: DSFont.Role
        ) {
            let theme = DSTheme.designSystem

            #expect(theme.font(for: role) == DSFont.font(for: role))
        }
    }
}
