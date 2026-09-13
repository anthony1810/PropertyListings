import Foundation

public protocol RemoteConfigStore: Sendable {
    func retrieve() async throws -> CachedRemoteConfig?
    func insert(_ configuration: LocalRemoteConfig, timestamp: Date) async throws
}
