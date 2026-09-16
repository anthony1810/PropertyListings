import Foundation

public struct RemoteConfigCachePolicy: Equatable, Sendable {
    private static let calendar = Calendar(identifier: .gregorian)

    public let maxAgeInDays: Int

    public init(maxAgeInDays: Int) {
        self.maxAgeInDays = maxAgeInDays
    }

    public func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxAge = Self.calendar.date(byAdding: .day, value: maxAgeInDays, to: timestamp)
        else {
            return false
        }
        return date < maxAge
    }
}
