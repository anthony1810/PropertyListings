import Foundation
import ListingsFeature
import Testing

@Suite struct ListingsCachePolicyTests {
    private let now = Date()

    @Test func validate_isTrueForCacheLessThanSevenDaysOld() {
        let timestamp = now.adding(days: -7).adding(seconds: 1)

        #expect(ListingsCachePolicy.validate(timestamp, against: now) == true)
    }

    @Test func validate_isFalseForCacheSevenDaysOld() {
        let timestamp = now.adding(days: -7)

        #expect(ListingsCachePolicy.validate(timestamp, against: now) == false)
    }

    @Test func validate_isFalseForCacheMoreThanSevenDaysOld() {
        let timestamp = now.adding(days: -7).adding(seconds: -1)

        #expect(ListingsCachePolicy.validate(timestamp, against: now) == false)
    }
}
