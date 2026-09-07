import Foundation

public enum AddressFormatter {
    public static func text(street: String?, postalCode: String?, locality: String) -> String {
        let cityLine = [postalCode, locality].compactMap(presence).joined(separator: " ")
        return [street, cityLine].compactMap(presence).joined(separator: ", ")
    }

    private static func presence(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else { return nil }
        return trimmed
    }
}
