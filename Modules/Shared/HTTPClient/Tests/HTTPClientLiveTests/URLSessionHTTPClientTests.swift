import Foundation
import Testing
import TestSupport
@testable import HTTPClientLive

@Suite(.serialized) final class URLSessionHTTPClientTests {
    deinit {
        URLProtocolStub.removeStub()
        leakTrackers.value.forEach { $0.verify() }
    }

    @Test func getFromURL_performsGETRequestWithURL() async {
        let url = URL(string: "https://a-specific-url.com")!
        let observed = LockIsolated<URLRequest?>(nil)
        URLProtocolStub.observeRequests { observed.setValue($0) }

        _ = try? await makeSUT().get(from: url)

        #expect(observed.value?.url == url)
        #expect(observed.value?.httpMethod == "GET")
    }

    @Test func getFromURL_failsOnRequestError() async {
        URLProtocolStub.stub(data: nil, response: nil, error: anyNSError())

        await #expect(throws: Error.self) {
            try await makeSUT().get(from: anyURL())
        }
    }

    @Test func getFromURL_failsOnNonHTTPURLResponse() async {
        let nonHTTP = URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        URLProtocolStub.stub(data: Data(), response: nonHTTP, error: nil)

        await #expect(throws: URLSessionHTTPClient.UnexpectedValuesRepresentation.self) {
            try await makeSUT().get(from: anyURL())
        }
    }

    @Test func getFromURL_succeedsOnHTTPURLResponseWithData() async throws {
        let data = Data("any data".utf8)
        let response = anyHTTPURLResponse(statusCode: 200)
        URLProtocolStub.stub(data: data, response: response, error: nil)

        let (receivedData, receivedResponse) = try await makeSUT().get(from: anyURL())

        #expect(receivedData == data)
        #expect(receivedResponse.url == response.url)
        #expect(receivedResponse.statusCode == response.statusCode)
    }

    // MARK: - Helpers

    private let leakTrackers = LockIsolated<[MemoryLeakTracker]>([])

    private func makeSUT(sourceLocation: SourceLocation = #_sourceLocation) -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let sut = URLSessionHTTPClient(session: URLSession(configuration: configuration))
        trackForMemoryLeaks(sut, sourceLocation: sourceLocation)
        return sut
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, sourceLocation: SourceLocation) {
        let tracker = MemoryLeakTracker(instance: instance, sourceLocation: sourceLocation)
        leakTrackers.withValue { $0.append(tracker) }
    }
}
