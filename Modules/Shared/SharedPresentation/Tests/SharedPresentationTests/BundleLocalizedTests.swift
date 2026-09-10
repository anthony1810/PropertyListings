import Foundation
import Testing
@testable import SharedPresentation

@Suite struct BundleLocalizedTests {
    private let bundle = SharedPresentationResources.bundle

    @Test func localized_resolvesStringsInTheLanguageOfTheLocale() {
        let french = bundle.localized(for: Locale(identifier: "fr"))

        #expect(String(localized: "price.onRequest", bundle: french) == "Prix sur demande")
    }

    @Test func localized_ignoresTheRegion() {
        let italianSwitzerland = bundle.localized(for: Locale(identifier: "it_CH"))

        #expect(String(localized: "price.onRequest", bundle: italianSwitzerland) == "Prezzo su richiesta")
    }

    @Test func localized_fallsBackToTheReceiverForAnUnknownLanguage() {
        let romansh = bundle.localized(for: Locale(identifier: "rm_CH"))

        #expect(romansh === bundle)
    }
}
