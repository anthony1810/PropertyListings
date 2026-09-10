import Foundation
import ListingsAPI
import ListingsFeature
import ListingsPresentation
import SettingsFeature
import SettingsPersistence
import SettingsPresentation
import SettingsTestSupport
import SharedPresentation
import Testing
import TestSupport
@testable import PropertyListings

@MainActor
struct SettingsAcceptanceTests {
    // MARK: - Narrative 1, language

    @Test func customerPicksFrench_seesEveryTabFollowAtOnce() async {
        let app = launch(online)
        await app.listings.load()
        let rowsInGerman = app.listings.rows

        await app.applyingSettings {
            await app.settings.select(language: .french)
        }

        #expect(app.listings.locale.identifier == "fr_CH", "the Listings tab formats for French Switzerland")
        #expect(app.saved.locale.identifier == "fr_CH", "the Saved tab formats for French Switzerland")
        #expect(app.settings.locale.identifier == "fr_CH", "the Settings tab formats for French Switzerland")
        #expect(app.listings.rows.map(\.id) == rowsInGerman.map(\.id), "the loaded listings stay on screen")
        #expect(app.listings.rows.first?.priceText == PriceFormatter.text(amount: 9_999_999, currency: "CHF", locale: frCH), "the price is formatted for French Switzerland")
    }

    @Test func customerPicksFrench_seesItKeptAfterRelaunch() async {
        let stores = AcceptanceApp.Stores()
        let firstLaunch = launch(online, sharing: stores)
        await firstLaunch.applyingSettings {
            await firstLaunch.settings.select(language: .french)
        }

        let secondLaunch = launch(online, sharing: stores)
        await secondLaunch.applyingSettings {}

        #expect(secondLaunch.settings.settings.language == .french, "the second launch comes up in French")
        #expect(secondLaunch.listings.locale.identifier == "fr_CH", "the Listings tab formats for French Switzerland on the second launch")
    }

    @Test func freshInstall_followsTheLanguageThePhoneChose() async {
        let app = launch(online)

        await app.applyingSettings {}

        #expect(app.settings.settings == makeSettings(appearance: .system, language: .german), "a fresh install shows the default the phone chose")
    }

    // MARK: - Narrative 2, appearance

    @Test func customerPicksDark_seesItKeptAfterRelaunch() async {
        let stores = AcceptanceApp.Stores()
        let firstLaunch = launch(online, sharing: stores)
        await firstLaunch.applyingSettings {
            await firstLaunch.settings.select(appearance: .dark)
        }
        #expect(firstLaunch.settings.settings.appearance == .dark, "dark is in effect at once")

        let secondLaunch = launch(online, sharing: stores)
        await secondLaunch.applyingSettings {}

        #expect(secondLaunch.settings.settings.appearance == .dark, "dark is still in effect after the relaunch")
    }

    @Test func customerPicksDarkAndSavingFails_seesSystemBackAndAnAlert() async {
        let app = launch(online, sharing: AcceptanceApp.Stores(settings: FailingSettingsStore(settings: nil)))

        await app.applyingSettings {
            await app.settings.select(appearance: .dark)
        }

        #expect(app.settings.settings.appearance == .system, "the previous choice is back")
        #expect(app.router.alert == .error(SettingsViewModel.Message.saveFailed(deCH)), "the router holds the not-saved alert")
    }

    // MARK: - Helpers

    private let now = Date()
    private let deCH = Locale(identifier: "de_CH")
    private let frCH = Locale(identifier: "fr_CH")
    private let clock = TestClock()
    private let listingsURL = ListingsEndpoint.page(from: 0, size: ListingsService.pageSize).url(baseURL: ServiceURLs.listings)
    private let house = makeRemoteListing(id: "1", title: "Haus", price: 9_999_999)

    private var online: HTTPClientStub {
        HTTPClientStub([listingsURL: [.success(makeItemsJSON([house.json]))]])
    }

    private func launch(_ client: HTTPClientStub, sharing stores: AcceptanceApp.Stores = AcceptanceApp.Stores()) -> AcceptanceApp {
        AcceptanceApp(client: client, stores: stores, today: LockIsolated(now), locale: deCH, clock: clock)
    }
}
