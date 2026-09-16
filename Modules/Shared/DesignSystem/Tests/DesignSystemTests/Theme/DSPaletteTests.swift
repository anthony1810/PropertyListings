import SwiftUI
import Testing
@testable import DesignSystem

@Suite struct DSPaletteTests {
    @Test func palette_resolvesFromTheBundle_whenItDefinesTheName() {
        let overriddenName = "accent"
        let fixtureAccent = Color(overriddenName, bundle: fixtureBundle)

        let palette = DSPalette(bundle: fixtureBundle)

        #expect(lightHex(of: palette.accent) == lightHex(of: fixtureAccent))
    }

    @Test func palette_fallsBackToTheDesignSystem_whenTheBundleLacksTheName() throws {
        let missingName = "surface"
        try #require(fixtureBundle.definesColor(named: missingName) == false)
        let designSystemSurface = Color(missingName, bundle: .designSystem)

        let palette = DSPalette(bundle: fixtureBundle)

        #expect(lightHex(of: palette.surface) == lightHex(of: designSystemSurface))
    }

    // MARK: - Helpers

    private var fixtureBundle: Bundle { .module }
}
