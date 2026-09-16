import BookmarksPersistence
import DesignSystem
import Foundation
import ListingsAPI
import ListingsCache
import SettingsFeature
import SettingsPersistence
import SettingsPresentation
import SwiftUI
import Testing
import TestSupport
import UIKit
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

    // MARK: - Settings

    @Test func settingsViewModel_supportsTheBrandLanguages() {
        let supported: [AppLanguage] = [.english, .french]
        let sut = makeSUT(brand: makeBrand(supportedLanguages: supported))

        #expect(sut.settingsViewModel.supportedLanguages == supported)
    }

    // MARK: - Theme

    @Test func theme_isTheBrandTheme() {
        let brandTheme = makeTheme(radii: DSRadii(m: 3, l: 5))
        let sut = makeSUT(brand: makeBrand(theme: brandTheme))

        #expect(sut.theme == brandTheme)
    }

    // MARK: - Remote configuration

    @Test func refreshBrandForTheNextLaunch_callsTheInjectedRefresh() async {
        let refreshed = LockIsolated(false)
        let sut = makeSUT(refreshBrand: { refreshed.setValue(true) })

        await sut.refreshBrandForTheNextLaunch()

        #expect(refreshed.value)
    }

    // MARK: - Tabs

    @Test func tabs_areTheBrandTabs() {
        let twoTabs = [
            BrandConfiguration.Tab(destination: .listings, icon: .image("Lighthouse")),
            BrandConfiguration.Tab(destination: .settings, icon: .image("Gear")),
        ]
        let sut = makeSUT(brand: makeBrand(tabs: twoTabs))

        #expect(sut.tabs == twoTabs)
    }

    // MARK: - Brand

    @Test func listingsViewModel_loadsListingsFromTheBrandHost() async {
        let brand = makeBrand(listingsHost: URL(string: "https://brand.example")!)
        let listing = makeRemoteListing(title: "From the brand host")
        let url = ListingsEndpoint.page(from: 0, size: brand.listings.pageSize).url(
            baseURL: brand.listings.host
        )
        let client = HTTPClientStub([url: [.success(makeItemsJSON([listing.json]))]])
        let sut = makeSUT(brand: brand, client: client)

        await sut.listingsViewModel.load()

        #expect(sut.listingsViewModel.rows.map(\.title) == ["From the brand host"])
    }

    @Test func listingsViewModel_requestsPagesOfTheBrandPageSize() async {
        let brand = makeBrand(listingsPageSize: 2)
        let listing = makeRemoteListing(title: "From a page of two")
        let url = ListingsEndpoint.page(from: 0, size: 2).url(baseURL: brand.listings.host)
        let client = HTTPClientStub([url: [.success(makeItemsJSON([listing.json]))]])
        let sut = makeSUT(brand: brand, client: client)

        await sut.listingsViewModel.load()

        #expect(sut.listingsViewModel.rows.map(\.title) == ["From a page of two"])
    }

    @Test func listingsViewModel_showsCachedListingsWithinTheBrandCacheAge() async {
        let brand = makeBrand(listingsCacheMaxAgeInDays: 30)
        let listing = makeRemoteListing(title: "Cached ten days ago")
        let cache = CachedListings(listings: [listing.local], timestamp: now.adding(days: -10))
        let sut = makeSUT(brand: brand, listingsStore: InMemoryListingsStore(cache: cache))

        await sut.listingsViewModel.load()

        #expect(sut.listingsViewModel.rows.map(\.title) == ["Cached ten days ago"])
    }

    // MARK: - Helpers

    private let now = Date()

    private let clock = TestClock()

    private func makeSUT(
        brand: BrandConfiguration = makeBrand(),
        client: HTTPClientStub = .offline,
        listingsStore: InMemoryListingsStore = InMemoryListingsStore(),
        refreshBrand: @escaping @Sendable () async -> Void = {}
    ) -> AppComposition {
        AppComposition(
            brand: brand,
            httpClient: client,
            listingsStore: listingsStore,
            bookmarkStore: InMemoryBookmarkStore(),
            settingsStore: InMemorySettingsStore(),
            refreshBrand: refreshBrand,
            preferredLanguageCodes: ["de"],
            currentDate: { now },
            locale: Locale(identifier: "de_CH"),
            clock: clock
        )
    }
}
