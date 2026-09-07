import Foundation

public enum PriceFormatter {
    public static let onRequest = "Price on request"

    public static func text(amount: Decimal?, currency: String?, locale: Locale) -> String {
        guard let amount, let currency else { return onRequest }
        return amount.formatted(
            .currency(code: currency)
                .locale(locale)
                .precision(.fractionLength(amount.isWhole ? 0 : 2))
        )
    }
}

private extension Decimal {
    var isWhole: Bool {
        var value = self
        var rounded = Decimal()
        NSDecimalRound(&rounded, &value, 0, .plain)
        return rounded == self
    }
}
