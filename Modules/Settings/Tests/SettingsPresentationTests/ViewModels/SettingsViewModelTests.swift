import Foundation
import SettingsFeature
import SettingsPresentation
import SettingsTestSupport
import Testing
import TestSupport

@MainActor
@Suite final class SettingsViewModelTests {
    @Test func init_startsFromTheInitialSettingsWithoutObserving() {
        let (sut, spy, _) = makeSUT(initial: makeSettings(appearance: .dark, language: .french))

        #expect(sut.settings == makeSettings(appearance: .dark, language: .french))
        #expect(sut.appliedSettings == makeSettings(appearance: .dark, language: .french))
        #expect(spy.receivedMessages == [])
    }

    // MARK: - Observe

    @Test func observe_subscribesToSettings() async {
        await withMainSerialExecutor {
            let (sut, spy, _) = makeSUT()

            let observation = Task { await sut.observe() }
            await Task.megaYield()

            #expect(spy.receivedMessages == [.observeSettings])
            await observation.cancelAndWait()
        }
    }

    @Test func observe_appliesEveryEmissionAtOnce() async {
        await withMainSerialExecutor {
            let (sut, spy, _) = makeSUT()
            let observation = Task { await sut.observe() }
            await Task.megaYield()

            spy.emitSettings(makeSettings(appearance: .dark, language: .italian))
            await Task.megaYield()

            #expect(sut.settings == makeSettings(appearance: .dark, language: .italian))
            #expect(sut.appliedSettings == makeSettings(appearance: .dark, language: .italian))
            await observation.cancelAndWait()
        }
    }

    @Test func observe_ignoresAnEmissionWhileAChoiceIsPending() async {
        await withMainSerialExecutor {
            let (sut, spy, _) = makeSUT(initial: makeSettings(appearance: .system))
            let observation = Task { await sut.observe() }
            await Task.megaYield()
            sut.select(appearance: .dark)
            await Task.megaYield()

            spy.emitSettings(makeSettings(appearance: .system))
            await Task.megaYield()

            #expect(sut.settings.appearance == .dark)
            await observation.cancelAndWait()
        }
    }

    // MARK: - Select appearance

    @Test func selectAppearance_flipsAtOnceAndAppliesAfterTheDebounce() async {
        await withMainSerialExecutor {
            let (sut, spy, clock) = makeSUT(initial: makeSettings(appearance: .system, language: .german))

            sut.select(appearance: .dark)
            await Task.megaYield()

            #expect(sut.settings.appearance == .dark)
            #expect(sut.appliedSettings.appearance == .system)
            #expect(spy.receivedMessages == [])
            await clock.advance(by: SettingsViewModel.debounce)
            #expect(sut.appliedSettings.appearance == .dark)
            #expect(spy.receivedMessages == [.saveSettings(makeSettings(appearance: .dark, language: .german))])
        }
    }

    @Test func selectAppearance_savesOnceWithTheFinalChoiceAfterRapidTaps() async {
        await withMainSerialExecutor {
            let (sut, spy, clock) = makeSUT(initial: makeSettings(appearance: .system))

            sut.select(appearance: .dark)
            await Task.megaYield()
            await clock.advance(by: SettingsViewModel.debounce / 2)
            sut.select(appearance: .light)
            await Task.megaYield()
            await clock.advance(by: SettingsViewModel.debounce / 2)

            #expect(sut.appliedSettings.appearance == .system)
            await clock.advance(by: SettingsViewModel.debounce / 2)
            #expect(sut.appliedSettings.appearance == .light)
            #expect(spy.receivedMessages == [.saveSettings(makeSettings(appearance: .light))])
        }
    }

    @Test func selectAppearance_savesNothingWhenTheTapsEndWhereTheyStarted() async {
        await withMainSerialExecutor {
            let (sut, spy, clock) = makeSUT(initial: makeSettings(appearance: .system))

            sut.select(appearance: .dark)
            await Task.megaYield()
            sut.select(appearance: .system)
            await Task.megaYield()
            await clock.advance(by: SettingsViewModel.debounce)

            #expect(sut.appliedSettings.appearance == .system)
            #expect(spy.receivedMessages == [])
        }
    }

    @Test func selectAppearance_ignoresTheCurrentValue() async {
        await withMainSerialExecutor {
            let (sut, spy, clock) = makeSUT(initial: makeSettings(appearance: .dark))

            sut.select(appearance: .dark)
            await Task.megaYield()
            await clock.advance(by: SettingsViewModel.debounce)

            #expect(spy.receivedMessages == [])
        }
    }

    @Test func selectAppearance_revertsAndNotifiesWhenSavingFails() async {
        await withMainSerialExecutor {
            let (sut, spy, clock) = makeSUT(initial: makeSettings(appearance: .light))
            spy.saveSettingsStub.complete(with: .failure(anyNSError()))

            sut.select(appearance: .dark)
            await Task.megaYield()
            await clock.advance(by: SettingsViewModel.debounce)

            #expect(sut.settings == makeSettings(appearance: .light))
            #expect(sut.appliedSettings == makeSettings(appearance: .light))
            #expect(spy.receivedMessages == [
                .saveSettings(makeSettings(appearance: .dark)),
                .notify(SettingsViewModel.Message.saveFailed(locale)),
            ])
        }
    }

    // MARK: - Select language

    @Test func selectLanguage_flipsAtOnceAndAppliesAfterTheDebounce() async {
        await withMainSerialExecutor {
            let (sut, spy, clock) = makeSUT(initial: makeSettings(appearance: .dark, language: .german))

            sut.select(language: .french)
            await Task.megaYield()

            #expect(sut.settings.language == .french)
            #expect(sut.appliedSettings.language == .german)
            await clock.advance(by: SettingsViewModel.debounce)
            #expect(sut.appliedSettings.language == .french)
            #expect(spy.receivedMessages == [.saveSettings(makeSettings(appearance: .dark, language: .french))])
        }
    }

    @Test func selectLanguage_savesOnceWithTheFinalChoiceAfterRapidTaps() async {
        await withMainSerialExecutor {
            let (sut, spy, clock) = makeSUT(initial: makeSettings(language: .german))

            sut.select(language: .french)
            await Task.megaYield()
            sut.select(language: .italian)
            await Task.megaYield()
            sut.select(language: .english)
            await Task.megaYield()
            await clock.advance(by: SettingsViewModel.debounce)

            #expect(sut.appliedSettings.language == .english)
            #expect(spy.receivedMessages == [.saveSettings(makeSettings(language: .english))])
        }
    }

    @Test func selectLanguage_ignoresTheCurrentValue() async {
        await withMainSerialExecutor {
            let (sut, spy, clock) = makeSUT(initial: makeSettings(language: .french))

            sut.select(language: .french)
            await Task.megaYield()
            await clock.advance(by: SettingsViewModel.debounce)

            #expect(spy.receivedMessages == [])
        }
    }

    @Test func selectLanguage_revertsAndNotifiesWhenSavingFails() async {
        await withMainSerialExecutor {
            let (sut, spy, clock) = makeSUT(initial: makeSettings(language: .german))
            spy.saveSettingsStub.complete(with: .failure(anyNSError()))

            sut.select(language: .italian)
            await Task.megaYield()
            await clock.advance(by: SettingsViewModel.debounce)

            #expect(sut.settings == makeSettings(language: .german))
            #expect(sut.appliedSettings == makeSettings(language: .german))
            #expect(spy.receivedMessages == [
                .saveSettings(makeSettings(language: .italian)),
                .notify(SettingsViewModel.Message.saveFailed(locale)),
            ])
        }
    }

    // MARK: - Update locale

    @Test func updateLocale_resolvesTheFailureMessageInTheNewLocale() async {
        await withMainSerialExecutor {
            let (sut, spy, clock) = makeSUT()
            let french = Locale(identifier: "fr_CH")
            spy.saveSettingsStub.complete(with: .failure(anyNSError()))
            sut.update(locale: french)

            sut.select(appearance: .dark)
            await Task.megaYield()
            await clock.advance(by: SettingsViewModel.debounce)

            #expect(sut.locale == french)
            #expect(spy.receivedMessages == [
                .saveSettings(makeSettings(appearance: .dark)),
                .notify(SettingsViewModel.Message.saveFailed(french)),
            ])
        }
    }

    // MARK: - Helpers

    private let locale = Locale(identifier: "de_CH")
    private let leakTrackers = LockIsolated<[MemoryLeakTracker]>([])

    deinit {
        leakTrackers.value.forEach { $0.verify() }
    }

    private func makeSUT(
        initial: Settings = makeSettings(),
        sourceLocation: SourceLocation = #_sourceLocation
    ) -> (sut: SettingsViewModel, spy: SettingsLoaderSpy, clock: TestClock<Duration>) {
        let spy = SettingsLoaderSpy()
        let clock = TestClock()
        let sut = SettingsViewModel(
            initial: initial,
            observeSettings: spy.observeSettings,
            saveSettings: spy.saveSettings,
            notify: spy.notify,
            locale: locale,
            clock: clock
        )
        trackForMemoryLeaks(sut, sourceLocation: sourceLocation)
        trackForMemoryLeaks(spy, sourceLocation: sourceLocation)
        return (sut, spy, clock)
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, sourceLocation: SourceLocation) {
        let tracker = MemoryLeakTracker(instance: instance, sourceLocation: sourceLocation)
        leakTrackers.withValue { $0.append(tracker) }
    }
}
