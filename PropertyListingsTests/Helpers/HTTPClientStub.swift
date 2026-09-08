import Foundation
import HTTPClient
import TestSupport

final class HTTPClientStub: HTTPClient {
    enum Outcome: Sendable {
        case success(Data)
        case failure
    }

    struct ConnectivityError: Error {}

    private let outcomes: LockIsolated<[URL: [Outcome]]>

    init(_ outcomes: [URL: [Outcome]]) {
        self.outcomes = LockIsolated(outcomes)
    }

    static var offline: HTTPClientStub { HTTPClientStub([:]) }

    func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        let outcome: Outcome = outcomes.withValue { queues in
            guard var queue = queues[url], !queue.isEmpty else { return .failure }
            let next = queue.removeFirst()
            queues[url] = queue
            return next
        }
        switch outcome {
        case let .success(data):
            return (data, okHTTPURLResponse(for: url))
        case .failure:
            throw ConnectivityError()
        }
    }
}
