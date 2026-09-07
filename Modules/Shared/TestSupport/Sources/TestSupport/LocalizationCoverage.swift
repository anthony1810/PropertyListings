import Foundation
import Testing

public func verifyLocalizationCoverage(
    in bundle: Bundle,
    languages: [String],
    table: String = "Localizable",
    sourceLocation: SourceLocation = #_sourceLocation
) {
    let present = Set(bundle.localizations)
    let absent = Set(languages).subtracting(present).sorted()
    #expect(absent.isEmpty, "Languages with no lproj: \(absent)", sourceLocation: sourceLocation)

    var keysByLanguage: [String: Set<String>] = [:]
    for language in languages where present.contains(language) {
        guard let strings = localizedStrings(in: bundle, language: language, table: table) else {
            Issue.record("No \(table).strings in \(language).lproj", sourceLocation: sourceLocation)
            continue
        }
        keysByLanguage[language] = Set(strings.keys)
        let untranslated = strings.filter { $0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || $0.value == $0.key }.keys.sorted()
        #expect(untranslated.isEmpty, "\(language) has untranslated keys: \(untranslated)", sourceLocation: sourceLocation)
    }

    let allKeys = keysByLanguage.values.reduce(into: Set<String>()) { $0.formUnion($1) }
    for (language, keys) in keysByLanguage.sorted(by: { $0.key < $1.key }) {
        let missing = allKeys.subtracting(keys).sorted()
        #expect(missing.isEmpty, "\(language) is missing keys: \(missing)", sourceLocation: sourceLocation)
    }
}

private func localizedStrings(in bundle: Bundle, language: String, table: String) -> [String: String]? {
    guard let path = bundle.path(forResource: language, ofType: "lproj"),
          let languageBundle = Bundle(path: path),
          let url = languageBundle.url(forResource: table, withExtension: "strings")
    else { return nil }
    return NSDictionary(contentsOf: url) as? [String: String]
}
