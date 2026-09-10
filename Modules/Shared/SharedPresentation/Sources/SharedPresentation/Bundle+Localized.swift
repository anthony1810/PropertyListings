import Foundation

public extension Bundle {
    func localized(for locale: Locale) -> Bundle {
        guard let code = locale.language.languageCode?.identifier,
              let path = path(forResource: code, ofType: "lproj"),
              let bundle = Bundle(path: path)
        else { return self }
        return bundle
    }
}
