import Foundation
import TestSupport

enum Fixture: String, FixtureNaming {
    static let bundle = Bundle.module

    case alpha = "FixtureCoverageTests_alpha"
    case beta = "FixtureCoverageTests_beta"
}

enum FixtureMissingACase: String, FixtureNaming {
    static let bundle = Bundle.module

    case alpha = "FixtureCoverageTests_alpha"
}

enum FixtureNamingAMissingFile: String, FixtureNaming {
    static let bundle = Bundle.module

    case alpha = "FixtureCoverageTests_alpha"
    case beta = "FixtureCoverageTests_beta"
    case gamma = "FixtureCoverageTests_gamma"
}
