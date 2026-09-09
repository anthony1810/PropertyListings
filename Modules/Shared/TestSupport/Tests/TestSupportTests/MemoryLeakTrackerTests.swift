import Foundation
import Testing
@testable import TestSupport

@Suite struct MemoryLeakTrackerTests {
    @Test func verify_recordsNothingWhenTheInstanceWasReleased() {
        let tracker = MemoryLeakTracker(instance: Instance(), sourceLocation: #_sourceLocation)
        tracker.verify()
    }

    @Test func verify_reportsALeakedInstance() {
        let leaked = Instance()
        let tracker = MemoryLeakTracker(instance: leaked, sourceLocation: #_sourceLocation)
        withKnownIssue {
            tracker.verify()
        }
        withExtendedLifetime(leaked) {}
    }
}

@Suite struct OptionalResultEvaluateTests {
    @Test func evaluate_throwsWhenNoResultWasSet() {
        let result: Result<Int, Error>? = nil
        #expect(throws: SpyError.self) {
            try result.evaluate()
        }
    }

    @Test func evaluate_returnsTheSuccessValue() throws {
        let result: Result<Int, Error>? = .success(42)
        #expect(try result.evaluate() == 42)
    }

    @Test func evaluate_rethrowsTheFailure() {
        let result: Result<Int, Error>? = .failure(anyNSError())
        #expect(throws: NSError.self) {
            try result.evaluate()
        }
    }
}

private final class Instance {}
