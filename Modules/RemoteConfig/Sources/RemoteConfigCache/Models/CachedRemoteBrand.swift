import Foundation

public struct CachedRemoteBrand: Equatable, Sendable {
    public let brand: LocalRemoteBrand
    public let timestamp: Date

    public init(brand: LocalRemoteBrand, timestamp: Date) {
        self.brand = brand
        self.timestamp = timestamp
    }
}
