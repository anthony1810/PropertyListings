import Foundation

enum AppStrings {
    static var listingsTab: String { localized("tab.listings") }
    static var savedTab: String { localized("tab.saved") }
    static var errorTitle: String { localized("alert.errorTitle") }
    static var ok: String { localized("alert.ok") }

    private static func localized(_ key: String.LocalizationValue) -> String {
        String(localized: key)
    }
}
