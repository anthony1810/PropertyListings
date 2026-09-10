import XCTest

@MainActor
struct SettingsTab {
    enum Language: String {
        case german = "de"
        case french = "fr"
        case italian = "it"
        case english = "en"
    }

    let app: XCUIApplication

    func pick(_ language: Language) {
        let row = app.descendants(matching: .any)["settings.language.\(language.rawValue)"]
        XCTAssertTrue(row.appears(), "expected the \(language) row on the Settings tab to tap")
        row.tap()
    }
}
