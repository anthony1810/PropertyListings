import BookmarksPersistence
import Foundation
import ListingsAPI
import ListingsCache
import SettingsFeature
import SettingsPersistence
import SettingsPresentation
import Testing
import TestSupport
@testable import PropertyListings

@MainActor
@Suite struct AppCompositionTests {
    @Test func listingsViewModel_isOneInstanceAcrossAccesses() {
        let sut = makeSUT()

        #expect(sut.listingsViewModel === sut.listingsViewModel)
    }

    @Test func bookmarksViewModel_isOneInstanceAcrossAccesses() {
        let sut = makeSUT()

        #expect(sut.bookmarksViewModel === sut.bookmarksViewModel)
    }

    @Test func settingsViewModel_isOneInstanceAcrossAccesses() {
        let sut = makeSUT()

        #expect(sut.settingsViewModel === sut.settingsViewModel)
    }

    // MARK: - Locale

    @Test func locale_keepsTheRegionAndTakesTheLanguage() {
        let sut = makeSUT()

        #expect(sut.locale(for: .french).identifier == "fr_CH")
        #expect(sut.locale(for: .italian).identifier == "it_CH")
    }

    @Test func observeSettings_updatesEveryViewModelWhenTheLanguageChanges() async {
        await withMainSerialExecutor {
            let sut = makeSUT()
            let observation = Task { await sut.observeSettings() }
            await Task.megaYield()

            sut.settingsViewModel.select(language: .french)
            await Task.megaYield()
            await clock.advance(by: SettingsViewModel.debounce)
            await Task.megaYield()

            #expect(sut.listingsViewModel.locale.identifier == "fr_CH")
            #expect(sut.bookmarksViewModel.locale.identifier == "fr_CH")
            #expect(sut.settingsViewModel.locale.identifier == "fr_CH")
            await observation.cancelAndWait()
        }
    }

    // MARK: - Brand

    @Test func listingsViewModel_loadsListingsFromTheBrandHost() async {
        let brand = makeBrand(listingsHost: URL(string: "https://brand.example")!)
        let listing = makeRemoteListing(title: "From the brand host")
        let url = ListingsEndpoint.page(from: 0, size: ListingsService.pageSize).url(baseURL: brand.listingsHost)
        let client = HTTPClientStub([url: [.success(makeItemsJSON([listing.json]))]])
        let sut = makeSUT(brand: brand, client: client)

        await sut.listingsViewModel.load()

        #expect(sut.listingsViewModel.rows.map(\.title) == ["From the brand host"])
    }

    // MARK: - Helpers

    private let clock = TestClock()

    private func makeSUT(
        brand: BrandConfiguration = makeBrand(),
        client: HTTPClientStub = .offline
    ) -> AppComposition {
        let now = Date()
        return AppComposition(
            brand: brand,
            httpClient: client,
            listingsStore: InMemoryListingsStore(),
            bookmarkStore: InMemoryBookmarkStore(),
            settingsStore: InMemorySettingsStore(),
            defaultSettings: Settings(appearance: .system, language: .german),
            currentDate: { now },
            locale: Locale(identifier: "de_CH"),
            clock: clock
        )
    }
}
