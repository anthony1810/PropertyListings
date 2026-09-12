import Testing
import UIKit
@testable import DesignSystem

extension RegistryTests {
    @MainActor
    @Suite final class DSAppearanceTests {
        deinit {
            DSTokens.configure(typeface: nil)
        }

        // MARK: - Navigation bar

        @Test func largeTitle_usesTheRegisteredBoldAtItsSize_whenATypefaceIsRegistered() throws {
            let brandTypeface = DSTypeface(
                regular: "HelveticaNeue",
                semibold: "HelveticaNeue-Medium",
                bold: "HelveticaNeue-Bold"
            )
            DSTokens.configure(typeface: brandTypeface)

            DSAppearance.configure()

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

            DSAppearance.configure()

            let font = try #require(
                UINavigationBar.appearance().titleTextAttributes?[.font] as? UIFont
            )
            #expect(font.fontName == brandTypeface.semibold)
            #expect(font.pointSize == DSFont.Role.title.size)
        }

        @Test func largeTitle_leavesTheSystemFont_whenNothingIsRegistered() {
            DSTokens.configure(typeface: nil)

            DSAppearance.configure()

            #expect(UINavigationBar.appearance().largeTitleTextAttributes?[.font] == nil)
        }

        @Test func largeTitle_isColouredWithTextPrimary() throws {
            DSTokens.configure(typeface: nil)
            let textPrimary = try #require(DSTokens.uiColor("textPrimary"))

            DSAppearance.configure()

            let colour = try #require(
                UINavigationBar.appearance().largeTitleTextAttributes?[.foregroundColor] as? UIColor
            )
            #expect(lightHex(of: colour) == lightHex(of: textPrimary))
        }

        // MARK: - Segmented control

        @Test func segment_usesTheRegisteredSemiboldAtCaptionSize_whenATypefaceIsRegistered() throws
        {
            DSTokens.configure(typeface: helveticaNeue)

            DSAppearance.configure()

            let selected = UISegmentedControl.appearance().titleTextAttributes(for: .selected)
            let font = try #require(selected?[.font] as? UIFont)
            #expect(font.fontName == helveticaNeue.semibold)
            #expect(font.pointSize == DSFont.Role.caption.size)
        }

        @Test func segment_usesTheRegisteredRegularAtCaptionSize_whenATypefaceIsRegistered() throws
        {
            DSTokens.configure(typeface: helveticaNeue)

            DSAppearance.configure()

            let normal = UISegmentedControl.appearance().titleTextAttributes(for: .normal)
            let font = try #require(normal?[.font] as? UIFont)
            #expect(font.fontName == helveticaNeue.regular)
            #expect(font.pointSize == DSFont.Role.caption.size)
        }

        @Test func segment_leavesTheSystemFont_whenNothingIsRegistered() {
            DSTokens.configure(typeface: nil)

            DSAppearance.configure()

            #expect(
                UISegmentedControl.appearance().titleTextAttributes(for: .normal)?[.font] == nil
            )
        }

        // MARK: - Helpers

        private let helveticaNeue = DSTypeface(
            regular: "HelveticaNeue",
            semibold: "HelveticaNeue-Medium",
            bold: "HelveticaNeue-Bold"
        )

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
}
