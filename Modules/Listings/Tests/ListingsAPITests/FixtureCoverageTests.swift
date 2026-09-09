import Testing
import TestSupport

@Suite struct FixtureCoverageTests {
    @Test func fixtures_casesAndFilesAgree() {
        verifyFixtureCoverage(Fixture.self)
    }
}
