import Testing
@testable import TestSupport

@Suite struct StubTests {
    @Test func call_throwsWhenNothingWasCompleted() async {
        let sut = Stub<Int>()

        await #expect(throws: SpyError.resultNotSet) {
            try await sut.call()
        }
    }

    @Test func call_deliversTheCompletedValue() async throws {
        let sut = Stub<Int>()
        sut.complete(with: .success(42))

        let value = try await sut.call()

        #expect(value == 42)
    }

    @Test func call_waitsForAHeldGateOnceThenRunsFreely() async throws {
        try await withMainSerialExecutor {
            let sut = Stub<Int>(.success(1))
            let gate = sut.holdNext()
            let held = Task { try await sut.call() }
            let arrived = LockIsolated(false)
            Task { _ = try await held.value; arrived.setValue(true) }
            await Task.megaYield()

            #expect(arrived.value == false)
            gate.open()
            await Task.megaYield()

            #expect(arrived.value == true)
            let heldValue = try await held.value
            let nextValue = try await sut.call()
            #expect(heldValue == 1)
            #expect(nextValue == 1)
        }
    }
}
