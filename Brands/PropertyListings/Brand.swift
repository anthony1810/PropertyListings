import DesignSystem
import Foundation
import SettingsFeature

enum CurrentBrand {
    static let source = BrandSource(
        documentURL: nil,
        fallback: BrandConfiguration(
            listings: BrandConfiguration.Listings(
                host: URL(string: "https://private-9f1bb1-homegate3.apiary-mock.com")!,
                pageSize: 5,
                cacheMaxAgeInDays: 7
            ),
            theme: DSTheme(
                colors: DSPalette(bundle: .main),
                radii: DSRadii(m: 12, l: 20),
                typeface: nil
            ),
            tabs: [
                BrandConfiguration.Tab(destination: .listings, icon: .symbol("house")),
                BrandConfiguration.Tab(destination: .saved, icon: .symbol("heart")),
                BrandConfiguration.Tab(
                    destination: .settings,
                    icon: .symbol("slider.horizontal.3")
                ),
            ],
            settings: BrandConfiguration.Settings(
                defaultLanguage: .english,
                supportedLanguages: [.german, .french, .italian, .english]
            )
        )
    )
}
