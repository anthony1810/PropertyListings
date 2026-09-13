import DesignSystem
import Foundation
import SettingsFeature
@testable import PropertyListings

func makeBrand(
    listingsHost: URL = URL(string: "https://brand.example")!,
    listingsPageSize: Int = 5,
    listingsCacheMaxAgeInDays: Int = 7,
    theme: DSTheme = makeTheme(),
    tabs: [BrandConfiguration.Tab] = [
        BrandConfiguration.Tab(destination: .listings, icon: .symbol("house")),
        BrandConfiguration.Tab(destination: .saved, icon: .symbol("heart")),
        BrandConfiguration.Tab(destination: .settings, icon: .symbol("slider.horizontal.3")),
    ],
    defaultLanguage: AppLanguage = .english,
    supportedLanguages: [AppLanguage] = AppLanguage.allCases
) -> BrandConfiguration {
    BrandConfiguration(
        listings: BrandConfiguration.Listings(
            host: listingsHost,
            pageSize: listingsPageSize,
            cacheMaxAgeInDays: listingsCacheMaxAgeInDays
        ),
        theme: theme,
        tabs: tabs,
        settings: BrandConfiguration.Settings(
            defaultLanguage: defaultLanguage,
            supportedLanguages: supportedLanguages
        )
    )
}

func makeTheme(
    colors: DSPalette = .designSystem,
    radii: DSRadii = .designSystem,
    typeface: DSTypeface? = nil
) -> DSTheme {
    DSTheme(colors: colors, radii: radii, typeface: typeface)
}
