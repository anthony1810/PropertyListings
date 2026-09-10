import Foundation

public enum PriceFormatter {
    public static func onRequest(_ locale: Locale) -> String {
        String(localized: "price.onRequest", bundle: .module.localized(for: locale))
    }

    public static func text(amount: Decimal?, currency: String?, locale: Locale) -> String {
        guard let amount, let currency else { return onRequest(locale) }
        return amount.formatted(
            .currency(code: currency)
                .locale(locale)
                .precision(.fractionLength(amount.isWhole ? 0 : 2))
        )
    }
}

public enum SharedPresentationResources {
    public static let bundle = Bundle.module
}

private extension Decimal {
    var isWhole: Bool {
        var value = self
        var rounded = Decimal()
        NSDecimalRound(&rounded, &value, 0, .plain)
        return rounded == self
    }
}
