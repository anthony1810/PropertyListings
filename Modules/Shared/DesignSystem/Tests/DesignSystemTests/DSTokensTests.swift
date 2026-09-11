import SwiftUI
import Testing
@testable import DesignSystem

@Suite(.serialized) struct DSTokensTests {
    @Test func accent_resolvesFromTheRegisteredBundle_whenItDefinesTheName() {
        let overriddenName = "accent"
        let fixtureAccent = Color(overriddenName, bundle: fixtureBundle)
        DSTokens.configure(bundle: fixtureBundle)
        defer { DSTokens.configure(bundle: nil) }

        #expect(lightHex(of: DSColor.accent) == lightHex(of: fixtureAccent))
    }

    @Test func surface_resolvesFromTheDesignSystemBundle_whenTheRegisteredBundleLacksTheName() throws {
        let missingName = "surface"
        let designSystemSurface = Color(missingName, bundle: designSystemBundle)
        try #require(fixtureBundle.definesColor(named: missingName) == false)
        DSTokens.configure(bundle: fixtureBundle)
        defer { DSTokens.configure(bundle: nil) }

        #expect(lightHex(of: DSColor.surface) == lightHex(of: designSystemSurface))
    }

    @Test func accent_resolvesFromTheDesignSystemBundle_whenNothingIsRegistered() {
        let designSystemAccent = Color("accent", bundle: designSystemBundle)
        DSTokens.configure(bundle: nil)

        #expect(lightHex(of: DSColor.accent) == lightHex(of: designSystemAccent))
    }

    // MARK: - Helpers

    private var fixtureBundle: Bundle { .module }
    private var designSystemBundle: Bundle { DSTokens.designSystemBundle }

    private func lightHex(of color: Color) -> String {
        let resolved = UIColor(color).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "%02X%02X%02X", Int(round(red * 255)), Int(round(green * 255)), Int(round(blue * 255)))
    }
}
