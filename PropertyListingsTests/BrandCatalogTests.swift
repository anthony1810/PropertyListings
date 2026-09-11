import DesignSystem
import Testing
import UIKit

@Suite struct BrandCatalogTests {
    @Test(arguments: DSColor.names)
    func brandCatalog_definesAColor_forEveryNameDSColorAsksFor(name: String) {
        #expect(brandCatalog.definesColor(named: name), "the brand catalog has no colorset named \(name)")
    }

    @Test(arguments: DSColor.names)
    func brandCatalog_definesADarkAppearance_forEveryNameDSColorAsksFor(name: String) throws {
        let colour = try #require(UIColor(named: name, in: brandCatalog, compatibleWith: nil))
        let light = colour.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        let dark = colour.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))

        #expect(light != dark, "\(name) resolves to the same colour in light and dark")
    }

    // MARK: - Helpers

    private var brandCatalog: Bundle { .main }
}

private extension Bundle {
    func definesColor(named name: String) -> Bool {
        UIColor(named: name, in: self, compatibleWith: nil) != nil
    }
}
