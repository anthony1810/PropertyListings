import Testing
import UIKit
@testable import DesignSystem

@MainActor
@Suite(.serialized) final class DSNavigationBarTests {
    deinit {
        DSTokens.configure(typeface: nil)
    }

    @Test func largeTitle_usesTheRegisteredBoldAtItsSize_whenATypefaceIsRegistered() throws {
        let brandTypeface = DSTypeface(
            regular: "HelveticaNeue",
            semibold: "HelveticaNeue-Medium",
            bold: "HelveticaNeue-Bold"
        )
        DSTokens.configure(typeface: brandTypeface)

        DSNavigationBar.configure()

        let font = try #require(
            UINavigationBar.appearance().largeTitleTextAttributes?[.font] as? UIFont
        )
        #expect(font.fontName == brandTypeface.bold)
        #expect(font.pointSize == DSFont.Role.largeTitle.size)
    }

    @Test func title_usesTheRegisteredSemiboldAtItsSize_whenATypefaceIsRegistered() throws {
        let brandTypeface = DSTypeface(
            regular: "HelveticaNeue",
            semibold: "HelveticaNeue-Medium",
            bold: "HelveticaNeue-Bold"
        )
        DSTokens.configure(typeface: brandTypeface)

        DSNavigationBar.configure()

        let font = try #require(UINavigationBar.appearance().titleTextAttributes?[.font] as? UIFont)
        #expect(font.fontName == brandTypeface.semibold)
        #expect(font.pointSize == DSFont.Role.title.size)
    }

    @Test func largeTitle_leavesTheSystemFont_whenNothingIsRegistered() {
        DSTokens.configure(typeface: nil)

        DSNavigationBar.configure()

        #expect(UINavigationBar.appearance().largeTitleTextAttributes?[.font] == nil)
    }

    @Test func largeTitle_isColouredWithTextPrimary() throws {
        DSTokens.configure(typeface: nil)
        let textPrimary = try #require(DSTokens.uiColor("textPrimary"))

        DSNavigationBar.configure()

        let colour = try #require(
            UINavigationBar.appearance().largeTitleTextAttributes?[.foregroundColor] as? UIColor
        )
        #expect(lightHex(of: colour) == lightHex(of: textPrimary))
    }

    // MARK: - Helpers

    private func lightHex(of colour: UIColor) -> String {
        let resolved = colour.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(
            format: "%02X%02X%02X",
            Int(round(red * 255)),
            Int(round(green * 255)),
            Int(round(blue * 255))
        )
    }
}
