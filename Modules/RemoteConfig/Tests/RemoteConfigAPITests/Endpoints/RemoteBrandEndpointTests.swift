import Foundation
import Testing
import TestSupport
@testable import RemoteConfigAPI

@Suite struct RemoteBrandEndpointTests {
    @Test func current_isTheConfigurationPathOnTheBaseURL() {
        let baseURL = anyURL()

        let url = RemoteBrandEndpoint.current.url(baseURL: baseURL)

        #expect(url == baseURL.appending(path: "configuration"))
    }
}
