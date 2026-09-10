import Foundation
import ListingsFeature
import Testing

@Suite struct ListingsCachePolicyTests {
    private let now = Date()
    private let sevenDays = ListingsCachePolicy(maxAgeInDays: 7)
    private let threeDays = ListingsCachePolicy(maxAgeInDays: 3)

    @Test func validate_isTrueForCacheLessThanSevenDaysOld_withASevenDayMaxAge() {
        let timestamp = now.adding(days: -7).adding(seconds: 1)

        #expect(sevenDays.validate(timestamp, against: now) == true)
    }

    @Test func validate_isFalseForCacheSevenDaysOld_withASevenDayMaxAge() {
        let timestamp = now.adding(days: -7)

        #expect(sevenDays.validate(timestamp, against: now) == false)
    }

    @Test func validate_isFalseForCacheMoreThanSevenDaysOld_withASevenDayMaxAge() {
        let timestamp = now.adding(days: -7).adding(seconds: -1)

        #expect(sevenDays.validate(timestamp, against: now) == false)
    }

    @Test func validate_isTrueForCacheLessThanThreeDaysOld_withAThreeDayMaxAge() {
        let timestamp = now.adding(days: -3).adding(seconds: 1)

        #expect(threeDays.validate(timestamp, against: now) == true)
    }

    @Test func validate_isFalseForCacheThreeDaysOld_withAThreeDayMaxAge() {
        let timestamp = now.adding(days: -3)

        #expect(threeDays.validate(timestamp, against: now) == false)
    }
}
