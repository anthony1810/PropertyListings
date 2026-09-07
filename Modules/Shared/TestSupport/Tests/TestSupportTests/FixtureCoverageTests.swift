import Foundation
import Testing
@testable import TestSupport

@Suite struct FixtureCoverageTests {
    @Test func casesAndFilesAgree() {
        verifyFixtureCoverage(Fixture.self)
    }

    @Test func reportsAFileWithNoCase() {
        withKnownIssue {
            verifyFixtureCoverage(FixtureMissingACase.self)
        }
    }

    @Test func reportsACaseWithNoFile() {
        withKnownIssue {
            verifyFixtureCoverage(FixtureNamingAMissingFile.self)
        }
    }

    @Test func data_loadsTheNamedFixture() throws {
        let data = try Fixture.alpha.data
        #expect(String(decoding: data, as: UTF8.self).contains("alpha"))
    }

    @Test func data_throwsForAMissingFixture() {
        #expect(throws: FixtureLoader.Error.self) {
            try FixtureNamingAMissingFile.gamma.data
        }
    }
}
