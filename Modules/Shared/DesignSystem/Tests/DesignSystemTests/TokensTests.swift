import SwiftUI
import Testing
@testable import DesignSystem

@Suite struct TokensTests {
    @Test(arguments: ["surface", "surfaceElevated", "textPrimary", "textSecondary", "accent", "like"])
    func colourAsset_exists(name: String) {
        #expect(UIColor(named: name, in: .module, compatibleWith: nil) != nil, "missing colour asset \(name)")
    }

    @Test(arguments: ["surface", "surfaceElevated", "textPrimary", "textSecondary", "accent", "like"])
    func colourAsset_hasADistinctDarkVariant(name: String) throws {
        let colour = try #require(UIColor(named: name, in: .module, compatibleWith: nil))
        let light = colour.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        let dark = colour.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
        #expect(light != dark, "\(name) has no dark appearance")
    }
}
