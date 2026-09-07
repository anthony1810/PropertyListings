import Foundation
import TestSupport

final class URLProtocolStub: URLProtocol {
    private struct Stub: Sendable {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let requestObserver: (@Sendable (URLRequest) -> Void)?
    }

    private static let _stub = LockIsolated<Stub?>(nil)

    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        _stub.setValue(Stub(data: data, response: response, error: error, requestObserver: nil))
    }

    static func observeRequests(_ observer: @escaping @Sendable (URLRequest) -> Void) {
        _stub.setValue(Stub(data: Data(), response: HTTPURLResponse(), error: nil, requestObserver: observer))
    }

    static func removeStub() {
        _stub.setValue(nil)
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let stub = Self._stub.value else { return }

        if let data = stub.data { client?.urlProtocol(self, didLoad: data) }
        if let response = stub.response { client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed) }
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }

        stub.requestObserver?(request)
    }

    override func stopLoading() {}
}
