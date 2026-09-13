import SwiftUI
import Testing
import UIKit
@testable import DesignSystem

@MainActor
@Suite(.serialized) struct DSAppearanceTests {
    @Test func largeTitle_usesTheThemeBoldAtItsSize_whenTheThemeHasATypeface() throws {
        let theme = makeTheme(typeface: helveticaNeue)

        DSAppearance.apply(theme)

        let font = try #require(UINavigationBar.appearance().largeTitleTextAttributes?[.font] as? UIFont)
        #expect(font.fontName == helveticaNeue.bold)
        #expect(font.pointSize == DSFont.Role.largeTitle.size)
    }

    @Test func title_usesTheThemeSemiboldAtItsSize_whenTheThemeHasATypeface() throws {
        let theme = makeTheme(typeface: helveticaNeue)

        DSAppearance.apply(theme)

        let font = try #require(UINavigationBar.appearance().titleTextAttributes?[.font] as? UIFont)
        #expect(font.fontName == helveticaNeue.semibold)
        #expect(font.pointSize == DSFont.Role.title.size)
    }

    @Test func segment_usesTheThemeAtCaptionSize_whenTheThemeHasATypeface() throws {
        let theme = makeTheme(typeface: helveticaNeue)

        DSAppearance.apply(theme)

        let selected = try #require(UISegmentedControl.appearance().titleTextAttributes(for: .selected)?[.font] as? UIFont)
        let normal = try #require(UISegmentedControl.appearance().titleTextAttributes(for: .normal)?[.font] as? UIFont)
        #expect(selected.fontName == helveticaNeue.semibold)
        #expect(normal.fontName == helveticaNeue.regular)
        #expect(selected.pointSize == DSFont.Role.caption.size)
    }

    @Test func largeTitle_leavesTheSystemFont_whenTheThemeHasNoTypeface() {
        DSAppearance.apply(makeTheme(typeface: nil))

        #expect(UINavigationBar.appearance().largeTitleTextAttributes?[.font] == nil)
    }

    @Test func largeTitle_isColouredWithTheThemeTextPrimary() throws {
        let theme = makeTheme(typeface: nil)

        DSAppearance.apply(theme)

        let colour = try #require(
            UINavigationBar.appearance().largeTitleTextAttributes?[.foregroundColor] as? UIColor
        )
        #expect(lightHex(of: colour) == lightHex(of: theme.colors.textPrimary))
    }

    // MARK: - Helpers

    private let helveticaNeue = DSTypeface(
        regular: "HelveticaNeue",
        semibold: "HelveticaNeue-Medium",
        bold: "HelveticaNeue-Bold"
    )

    private func makeTheme(typeface: DSTypeface?) -> DSTheme {
        DSTheme(colors: .designSystem, radii: .designSystem, typeface: typeface)
    }
}
