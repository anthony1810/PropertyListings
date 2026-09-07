import Foundation
import Testing
@testable import ListingsAPI

@Suite struct ListingsEndpointTests {
    @Test func get_appendsThePropertiesPathToTheBaseURL() {
        let baseURL = URL(string: "https://base-url.com")!

        let url = ListingsEndpoint.get.url(baseURL: baseURL)

        #expect(url == URL(string: "https://base-url.com/properties"))
    }

    @Test func get_keepsAnExistingBasePath() {
        let baseURL = URL(string: "https://base-url.com/v1")!

        let url = ListingsEndpoint.get.url(baseURL: baseURL)

        #expect(url == URL(string: "https://base-url.com/v1/properties"))
    }
}
