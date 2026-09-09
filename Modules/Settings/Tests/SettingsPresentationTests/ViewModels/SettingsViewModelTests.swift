import Foundation
import SettingsFeature
import SettingsPresentation
import SettingsTestSupport
import Testing
import TestSupport

@MainActor
@Suite final class SettingsViewModelTests {
    @Test func init_startsFromTheInitialSettingsWithoutObserving() {
        let (sut, spy) = makeSUT(initial: makeSettings(appearance: .dark, language: .french))

        #expect(sut.settings == makeSettings(appearance: .dark, language: .french))
        #expect(spy.receivedMessages == [])
    }

    // MARK: - Observe

    @Test func observe_subscribesToSettings() async {
        await withMainSerialExecutor {
            let (sut, spy) = makeSUT()

            let observation = Task { await sut.observe() }
            await Task.megaYield()

            #expect(spy.receivedMessages == [.observeSettings])
            await observation.cancelAndWait()
        }
    }

    @Test func observe_appliesEveryEmission() async {
        await withMainSerialExecutor {
            let (sut, spy) = makeSUT()
            let observation = Task { await sut.observe() }
            await Task.megaYield()

            spy.emitSettings(makeSettings(appearance: .dark, language: .italian))
            await Task.megaYield()

            #expect(sut.settings == makeSettings(appearance: .dark, language: .italian))
            await observation.cancelAndWait()
        }
    }

    // MARK: - Select appearance

    @Test func selectAppearance_appliesAtOnceAndSaves() async {
        let (sut, spy) = makeSUT(initial: makeSettings(appearance: .system, language: .german))

        await sut.select(appearance: .dark)

        #expect(sut.settings == makeSettings(appearance: .dark, language: .german))
        #expect(spy.receivedMessages == [.saveSettings(makeSettings(appearance: .dark, language: .german))])
    }

    @Test func selectAppearance_ignoresTheCurrentValue() async {
        let (sut, spy) = makeSUT(initial: makeSettings(appearance: .dark))

        await sut.select(appearance: .dark)

        #expect(spy.receivedMessages == [])
    }

    @Test func selectAppearance_revertsAndNotifiesWhenSavingFails() async {
        let (sut, spy) = makeSUT(initial: makeSettings(appearance: .light))
        spy.saveSettingsStub.complete(with: .failure(anyNSError()))

        await sut.select(appearance: .dark)

        #expect(sut.settings == makeSettings(appearance: .light))
        #expect(spy.receivedMessages == [
            .saveSettings(makeSettings(appearance: .dark)),
            .notify(SettingsViewModel.Message.saveFailed(locale)),
        ])
    }

    // MARK: - Select language

    @Test func selectLanguage_appliesAtOnceAndSaves() async {
        let (sut, spy) = makeSUT(initial: makeSettings(appearance: .dark, language: .german))

        await sut.select(language: .french)

        #expect(sut.settings == makeSettings(appearance: .dark, language: .french))
        #expect(spy.receivedMessages == [.saveSettings(makeSettings(appearance: .dark, language: .french))])
    }

    @Test func selectLanguage_ignoresTheCurrentValue() async {
        let (sut, spy) = makeSUT(initial: makeSettings(language: .french))

        await sut.select(language: .french)

        #expect(spy.receivedMessages == [])
    }

    @Test func selectLanguage_revertsAndNotifiesWhenSavingFails() async {
        let (sut, spy) = makeSUT(initial: makeSettings(language: .german))
        spy.saveSettingsStub.complete(with: .failure(anyNSError()))

        await sut.select(language: .italian)

        #expect(sut.settings == makeSettings(language: .german))
        #expect(spy.receivedMessages == [
            .saveSettings(makeSettings(language: .italian)),
            .notify(SettingsViewModel.Message.saveFailed(locale)),
        ])
    }

    // MARK: - Update locale

    @Test func updateLocale_resolvesTheFailureMessageInTheNewLocale() async {
        let (sut, spy) = makeSUT()
        let french = Locale(identifier: "fr_CH")
        spy.saveSettingsStub.complete(with: .failure(anyNSError()))

        sut.update(locale: french)
        await sut.select(appearance: .dark)

        #expect(sut.locale == french)
        #expect(spy.receivedMessages == [
            .saveSettings(makeSettings(appearance: .dark)),
            .notify(SettingsViewModel.Message.saveFailed(french)),
        ])
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
    ) -> (sut: SettingsViewModel, spy: SettingsLoaderSpy) {
        let spy = SettingsLoaderSpy()
        let sut = SettingsViewModel(
            initial: initial,
            observeSettings: spy.observeSettings,
            saveSettings: spy.saveSettings,
            notify: spy.notify,
            locale: locale
        )
        trackForMemoryLeaks(sut, sourceLocation: sourceLocation)
        trackForMemoryLeaks(spy, sourceLocation: sourceLocation)
        return (sut, spy)
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, sourceLocation: SourceLocation) {
        let tracker = MemoryLeakTracker(instance: instance, sourceLocation: sourceLocation)
        leakTrackers.withValue { $0.append(tracker) }
    }
}
