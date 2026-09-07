import Foundation
import Testing
@testable import TestSupport

@Suite struct FixtureCoverageTests {
    @Test func verifyFixtureCoverage_passes_whenCasesAndFilesAgree() {
        verifyFixtureCoverage(Fixture.self)
    }

    @Test func verifyFixtureCoverage_reportsAFileWithNoCase() {
        withKnownIssue {
            verifyFixtureCoverage(FixtureMissingACase.self)
        }
    }

    @Test func verifyFixtureCoverage_reportsACaseWithNoFile() {
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
