import Foundation
import Testing
import TestSupport
@testable import RemoteConfigAPI

@Suite struct RemoteConfigEndpointTests {
    @Test func current_isTheConfigurationPathOnTheBaseURL() {
        let baseURL = anyURL()

        let url = RemoteConfigEndpoint.current.url(baseURL: baseURL)

        #expect(url == baseURL.appending(path: "configuration"))
    }
}
