import Foundation
import Testing
@testable import ListingsAPI

@Suite struct ListingsEndpointTests {
    @Test func page_appendsThePropertiesPathAndTheOffsetAndSizeQuery() {
        let baseURL = URL(string: "https://base-url.com")!

        let url = ListingsEndpoint.page(from: 0, size: 5).url(baseURL: baseURL)

        #expect(url == URL(string: "https://base-url.com/properties?from=0&size=5"))
    }

    @Test func page_keepsAnExistingBasePath() {
        let baseURL = URL(string: "https://base-url.com/v1")!

        let url = ListingsEndpoint.page(from: 10, size: 5).url(baseURL: baseURL)

        #expect(url == URL(string: "https://base-url.com/v1/properties?from=10&size=5"))
    }
}
