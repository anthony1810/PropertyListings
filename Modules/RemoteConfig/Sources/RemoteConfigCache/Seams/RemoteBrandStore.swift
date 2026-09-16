import Foundation

public protocol RemoteBrandStore: Sendable {
    func retrieve() async throws -> CachedRemoteBrand?
    func insert(_ brand: LocalRemoteBrand, timestamp: Date) async throws
}
