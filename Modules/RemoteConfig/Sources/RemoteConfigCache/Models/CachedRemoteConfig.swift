import Foundation

public struct CachedRemoteConfig: Equatable, Sendable {
    public let configuration: LocalRemoteConfig
    public let timestamp: Date

    public init(configuration: LocalRemoteConfig, timestamp: Date) {
        self.configuration = configuration
        self.timestamp = timestamp
    }
}
