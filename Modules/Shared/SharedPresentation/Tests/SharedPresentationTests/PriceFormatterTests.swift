import Foundation
import Testing
@testable import SharedPresentation

@Suite struct PriceFormatterTests {
    private let deCH = Locale(identifier: "de_CH")
    private let enUS = Locale(identifier: "en_US")

    @Test func text_wholeAmount_hasNoDecimalsAndSwissGrouping() {
        #expect(PriceFormatter.text(amount: 9_999_999, currency: "CHF", locale: deCH) == chf("9'999'999"))
    }

    @Test func text_showsTwoCentimeDigitsWhenPresent() {
        #expect(PriceFormatter.text(amount: Decimal(string: "1250.5")!, currency: "CHF", locale: deCH) == chf("1'250.50"))
    }

    @Test func text_formatsTheFifteenDigitPriceExactly() {
        #expect(PriceFormatter.text(amount: Decimal(string: "999999999999999")!, currency: "CHF", locale: deCH) == chf("999'999'999'999'999"))
    }

    @Test func text_followsTheInjectedLocale() {
        #expect(PriceFormatter.text(amount: 9_999_999, currency: "CHF", locale: enUS) == chf("9,999,999"))
    }

    @Test func text_fallsBackToOnRequestWithoutAmount() {
        #expect(PriceFormatter.text(amount: nil, currency: "CHF", locale: deCH) == "Price on request")
    }

    @Test func text_fallsBackToOnRequestWithoutCurrency() {
        #expect(PriceFormatter.text(amount: 100, currency: nil, locale: deCH) == "Price on request")
    }

    // MARK: - Helpers

    private func chf(_ number: String) -> String {
        "CHF\u{00A0}\(number)"
    }
}
