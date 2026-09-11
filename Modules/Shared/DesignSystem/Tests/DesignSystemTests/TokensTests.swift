import SwiftUI
import Testing
@testable import DesignSystem

@Suite struct TokensTests {
    @Test(arguments: DSColor.names)
    func designSystemCatalog_definesAColor_forEveryNameDSColorAsksFor(name: String) {
        #expect(designSystemCatalog.definesColor(named: name), "DesignSystem's catalog has no colorset named \(name)")
    }

    @Test(arguments: DSColor.names)
    func designSystemCatalog_definesADarkAppearance_forEveryNameDSColorAsksFor(name: String) throws {
        let colour = try #require(UIColor(named: name, in: designSystemCatalog, compatibleWith: nil))
        let light = colour.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        let dark = colour.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))

        #expect(light != dark, "\(name) resolves to the same colour in light and dark")
    }

    // MARK: - Helpers

    private var designSystemCatalog: Bundle { DSTokens.designSystemBundle }
}

extension Bundle {
    func definesColor(named name: String) -> Bool {
        UIColor(named: name, in: self, compatibleWith: nil) != nil
    }
}
