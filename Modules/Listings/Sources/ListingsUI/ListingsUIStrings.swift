import Foundation

public enum ListingsUIStrings {
    public static var title: String { localized("listings.title") }

    private static func localized(_ key: String.LocalizationValue) -> String {
        String(localized: key, bundle: ListingsUIResources.bundle)
    }
}

public enum ListingsUIResources {
    public static let bundle = Bundle.module
}
