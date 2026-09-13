# PropertyListings

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![iOS](https://img.shields.io/badge/iOS-18.0-blue.svg)
![Xcode](https://img.shields.io/badge/Xcode-26-blue.svg)
[![Tests](https://github.com/anthony1810/PropertyListings/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/anthony1810/PropertyListings/actions/workflows/tests.yml)
[![Live](https://github.com/anthony1810/PropertyListings/actions/workflows/live.yml/badge.svg?branch=main)](https://github.com/anthony1810/PropertyListings/actions/workflows/live.yml)

A SwiftUI app that lists real estate from a REST endpoint, lets you bookmark listings on the device, and
switches language and appearance in place. iOS 18.0, Xcode 26, Swift 6.

It is built as a white label product: one codebase, one app per brand. `PropertyListings` and `Lakeside`
are two apps compiled from the same source, each with its own bundle identifier, icon, launch screen,
palette, typeface, tab set, languages and backend. A brand can also be reconfigured after release, with no
new binary, from a JSON document it fetches on launch.

## Architecture

Horizontal layers inside vertical feature slices, the hybrid approach described in
[iOS Modular Architecture: From Monolith to Hybrid Approaches](https://medium.com/@qquang269/ios-modular-architecture-from-monolith-to-hybrid-approaches-979f827886fb?sk=88d55954082b3a29a859499ec2cf0d06)
by Anthony Tran. Each feature is one Swift package with UI, Presentation, Feature and data targets. Shared
modules carry implementation only. The app target is the composition root, the only place concrete types meet.

<p align="center">
  <img alt="PropertyListings architecture overview" src="docs/architecture-overview.svg" width="900">
</p>

The architecture is enforced, not documented: [`Scripts/architecture-guard.sh`](Scripts/architecture-guard.sh)
runs as a pre-build phase of the app target and as the first step of CI, and fails the build on any import
that crosses a module boundary.

| # | Rule | Why |
|---|---|---|
| 1 | SwiftUI and UIKit may only be imported by the UI targets and the app. Presentation and data targets are not allowed to import them. | UI is the only layer that depends on iOS. The rest of the system stays agnostic, so the same code can back a Mac app, a CLI, or even an Android app. |
| 2 | Listings, Bookmarks and Settings never import each other. | Each feature knows nothing about the others, so they can be composed and reused anywhere without coupling. |
| 3 | Kingfisher may only be imported inside DesignSystem. | One place to swap the image pipeline. |
| 4 | HTTPClient may only be imported by the composition root and its own live module, never by a feature. | The API layer of a feature stays agnostic of how the request is made, Alamofire or URLSession alike. |
| 5 | The backend host is named in one file, the brand's `Brand.swift`, plus the end to end test. | One file to change when the backend environment changes, and a second brand is a second file, not a search. |
| 6 | A TestSupport module may only be linked by a test bundle. | Test doubles never ship. |
| 7 | ListingsAPI and ListingsCache never import each other. | The two infrastructure layers know nothing about each other, so when either one has to go, the other stays intact. |
| 8 | A feature package never names a brand: `CurrentBrand` and `BrandConfiguration` exist only in the composition root and the `Brands/` folders. | Features are built once and linked by every brand. The brand is decided in one place, the root, and a feature that knew its brand could not be reused by the next one. |
| 9 | No file names `DSTokens`, `DSColor.` or `DSRadius.`: the design system is read through a `DSTheme` injected into the environment. | A component that asks a global for its colours hides that it has a theme at all, and makes two brands impossible to render in one process. The theme is an input, like every other dependency. |

## Module map

<p align="center">
  <img alt="Module map" src="docs/module-map.svg" width="900">
</p>

| Document | Link | What it holds |
|---|---|---|
| BDD specs for Listings | [docs/specs/listings.md](docs/specs/listings.md) | How a customer uses the Listings tab, as Given, When, Then scenarios: online, offline, paging, retry. Each scenario is what one acceptance test proves, and the map at the end names that test. |
| BDD specs for Bookmarks | [docs/specs/bookmarks.md](docs/specs/bookmarks.md) | How a customer likes a listing, relaunches, and uses the Saved tab, as Given, When, Then scenarios. Each scenario is what one acceptance test proves, and the map at the end names that test. |
| BDD specs for Settings | [docs/specs/settings.md](docs/specs/settings.md) | How a customer switches language and appearance, and what survives a relaunch, as Given, When, Then scenarios. Each scenario is what one acceptance test proves, and the map at the end names that test. |
| Figma design | [PropertyListings on Figma](https://www.figma.com/design/mGYnBSubQuhnIJkenp8aMC) | Foundations, components and every screen in light and dark. Anyone with the link can view. |

## White label

Two rules let one codebase serve many brands.

**A feature never knows which brand it is in.** Every module under `Modules/` is compiled once and linked
by every brand. Guard rule 8 fails the build if a feature names `CurrentBrand` or `BrandConfiguration`.
Guard rule 9 fails it if any file reads a global design token instead of the `DSTheme` the root injects
into the environment. A feature that knew its brand could not be reused by the next one.

**A brand is a folder and four lines of `project.yml`.** Everything a brand owns lives in
`Brands/<Brand>/`, and the target that compiles it comes from one template, so two brands cannot drift
apart in build settings.

<table>
  <tr>
    <th colspan="2">PropertyListings</th>
    <th colspan="2">Lakeside</th>
  </tr>
  <tr>
    <td><img src="PropertyListingsTests/Brand/__Snapshots__/BrandSnapshotTests/PropertyListings/root.light.png" width="150" alt="PropertyListings, light"></td>
    <td><img src="PropertyListingsTests/Brand/__Snapshots__/BrandSnapshotTests/PropertyListings/root.dark.png" width="150" alt="PropertyListings, dark"></td>
    <td><img src="PropertyListingsTests/Brand/__Snapshots__/BrandSnapshotTests/Lakeside/root.light.png" width="150" alt="Lakeside, light"></td>
    <td><img src="PropertyListingsTests/Brand/__Snapshots__/BrandSnapshotTests/Lakeside/root.dark.png" width="150" alt="Lakeside, dark"></td>
  </tr>
</table>

Both pairs are recorded references from `BrandSnapshotTests`, run inside each brand's own app.

### What a brand owns

| File | What it decides |
|---|---|
| `Brands/<Brand>/Brand.swift` | the one constant the app reads: where this brand's remote document lives, and the configuration to use until one arrives |
| `Brands/<Brand>/Info.plist` | display name, launch screen, registered fonts |
| `Brands/<Brand>/Assets.xcassets` | app icon, launch mark, accent, and the semantic colours the design system resolves by name |
| `Brands/<Brand>/Fonts` | the typeface files, for a brand that ships one |

`BrandConfiguration` holds the rest: the listings host, page size and cache age, the theme, the tab set,
and the default and supported languages. No feature reads it. The composition root turns it into services,
view models and views, and that root is the only place a concrete brand and a concrete feature meet.

| | PropertyListings | Lakeside |
|---|---|---|
| Bundle identifier | `com.anthony.propertylistings` | `com.anthony.lakeside` |
| Accent | blue | pink |
| Typeface | system | Fraunces |
| Corner radii | 12 and 20 | 16 and 28 |
| Tabs | Listings, Saved, Settings | Listings, Settings |
| Languages | German, French, Italian, English | English, Vietnamese |
| Listings source | the sample endpoint | its own mock, eight lakeside properties |
| Remote document | none | [docs/mock/lakeside/configuration](docs/mock/lakeside/configuration) |

### Configuration after release

`Modules/RemoteConfig` is a vertical like the other three, with a feature target, an API target and a cache
target, and no UI. It fetches one document, maps it and caches it. It has never heard of a brand: languages
and tabs are raw strings to it, and only the composition root turns a document into a `BrandConfiguration`.

On launch the app reads the cached document, never the network. If one is there and every field is
acceptable, it becomes the brand for this session. Otherwise the compiled fallback is used whole. The
refresh runs in the background for the next launch, so the network is never on the path to the first frame,
and a half written document can never half configure the app.

| Part of the brand | The build | A document | Why |
|---|---|---|---|
| Bundle identifier, display name | yes | no | only a new binary can change them |
| App icon, launch screen | yes | no | the system reads them before any code runs |
| Colours, radii, typeface | yes | no | catalogs and font files live in the binary, and a remote restyle would leave the icon and launch screen behind |
| Tab icons | yes | no | a symbol name or an image has to exist in the app |
| Translations | yes | no | compiled string catalogs, covered by the localization tests |
| Listings host | yes | yes | environment switching, HTTPS enforced |
| Page size, cache age | yes | yes | numbers with no assets behind them |
| Default and supported languages | yes | yes | can only choose among the catalogs already shipped |
| Tab set and order | yes | yes | can narrow and reorder what the app already builds |

### Add a brand

1. Copy `Brands/PropertyListings/` to `Brands/<NewBrand>/`, then replace the icon, the launch mark and the colours.
2. Write its `Brand.swift`: the fallback configuration, and a document URL if the brand has one.
3. Add one app target and one test target to `project.yml`, four lines, then run `xcodegen`.
4. Add the scheme to the `app` matrix in `.github/workflows/tests.yml`.
5. Record its snapshots with `SNAPSHOT_RECORD=1`, and commit the folder they land in under `PropertyListingsTests/Brand/__Snapshots__/BrandSnapshotTests/<NewBrand>/`.

No feature package is touched by any of those five steps.

## Continuous integration

Two workflows run on every pull request to `main` and every push to `main`. `Tests` is the gate: its
`all-green` job needs every other job and is the one required check on the protected branch. `Live` runs
the tests that need the network and reports on the pull request and its own badge without blocking a merge.

<p align="center">
  <img alt="CI jobs" src="docs/ci.svg" width="900">
</p>

| Workflow | Job | What it runs |
|---|---|---|
| Tests | `host-packages` | `swift test` for TestSupport and HTTPClient on the Mac, no simulator |
| Tests | `simulator-packages` | `xcodebuild test` for SharedPresentation, DesignSystem, Listings, Bookmarks, Settings and RemoteConfig on iPhone 17, for catalogs, locale formatting and snapshots |
| Tests | `app` | the architecture guard, then one brand scheme per matrix entry, `PropertyListings` and `Lakeside`, with the UI tests skipped: the unit and acceptance suite hosted by that brand's app, so a brand that stops compiling or ships a broken catalog fails the merge |
| Tests | `all-green` | nothing, the one name branch protection requires |
| Live | `end-to-end` | `PropertyListingsEndToEndTests` on the Mac against the live endpoint |
| Live | `ui-tests` | `PropertyListingsUITests` on iPhone 17, eight scenarios launching the app with `-reset` and `-connectivity offline` |

## Testing strategy (93% Test Coverage as of 13 September 2026)

358 tests in five kinds, each aimed at one risk. The widest tier runs most often. The app suite is counted
once here and runs twice on CI, 89 tests under each brand scheme.

- **Unit Tests**: 305 tests in total, proving the correctness of the smallest units of code, one type at a time.
- **Snapshot Tests**: 16 tests in total, 36 recorded references, proving every screen state renders as designed in light and dark, and each brand renders as its own product.
- **Acceptance Tests**: 28 tests in total, guaranteeing the behaviours listed in [BDD Specs: Listings](docs/specs/listings.md), [BDD Specs: Bookmarks](docs/specs/bookmarks.md) and [BDD Specs: Settings](docs/specs/settings.md).
- **UI Automation Tests**: 8 tests in total, driving the shipped app on a simulator against the live endpoint.
- **End to End Tests**: 1 test in total, proving the live endpoint still answers in the shape the mapper expects.

<p align="center">
  <img alt="Test pyramid" src="docs/test-pyramid.svg" width="900">
</p>

Line coverage from the unit, snapshot and acceptance runs, measured with `xccov` on 13 September 2026. Every
figure below was re-measured after the brand work, the theme migration and the RemoteConfig vertical, and
every one of them held.

| Feature | Target | Coverage | Locations |
|---|---|---|---|
| Listings | ListingsFeature | 96% | [ListingsCachePolicyTests](Modules/Listings/Tests/ListingsFeatureTests/Policies/ListingsCachePolicyTests.swift) |
| Listings | ListingsAPI | 98% | [ListingsEndpointTests](Modules/Listings/Tests/ListingsAPITests/Endpoints/ListingsEndpointTests.swift), [ListingsMapperTests](Modules/Listings/Tests/ListingsAPITests/Mappers/ListingsMapperTests.swift), [ListingsPageTests](Modules/Listings/Tests/ListingsAPITests/Models/ListingsPageTests.swift), [FixtureCoverageTests](Modules/Listings/Tests/ListingsAPITests/FixtureCoverageTests.swift) |
| Listings | ListingsCache | 100% | [LocalListingsLoaderTests](Modules/Listings/Tests/ListingsCacheTests/Loaders/LocalListingsLoaderTests.swift), [CodableListingsStoreTests](Modules/Listings/Tests/ListingsCacheTests/Infrastructure/Codable/CodableListingsStoreTests.swift), [InMemoryListingsStoreTests](Modules/Listings/Tests/ListingsCacheTests/Infrastructure/InMemory/InMemoryListingsStoreTests.swift) |
| Listings | ListingsPresentation | 100% | [ListingRowMapperTests](Modules/Listings/Tests/ListingsPresentationTests/Mappers/ListingRowMapperTests.swift), [ListingsViewModelTests](Modules/Listings/Tests/ListingsPresentationTests/ViewModels/ListingsViewModelTests.swift), [LocalizationTests](Modules/Listings/Tests/ListingsPresentationTests/LocalizationTests.swift) |
| Listings | ListingsUI | 69% | [ListingsViewSnapshotTests](Modules/Listings/Tests/ListingsUITests/Views/ListingsViewSnapshotTests.swift), [LocalizationTests](Modules/Listings/Tests/ListingsUITests/LocalizationTests.swift) |
| Bookmarks | BookmarksFeature | 100% | covered through the Persistence and Presentation suites |
| Bookmarks | BookmarksPersistence | 99% | [LocalBookmarksLoaderTests](Modules/Bookmarks/Tests/BookmarksPersistenceTests/Loaders/LocalBookmarksLoaderTests.swift), [CodableBookmarkStoreTests](Modules/Bookmarks/Tests/BookmarksPersistenceTests/Infrastructure/Codable/CodableBookmarkStoreTests.swift), [InMemoryBookmarkStoreTests](Modules/Bookmarks/Tests/BookmarksPersistenceTests/Infrastructure/InMemory/InMemoryBookmarkStoreTests.swift) |
| Bookmarks | BookmarksPresentation | 100% | [BookmarkRowMapperTests](Modules/Bookmarks/Tests/BookmarksPresentationTests/Mappers/BookmarkRowMapperTests.swift), [BookmarksViewModelTests](Modules/Bookmarks/Tests/BookmarksPresentationTests/ViewModels/BookmarksViewModelTests.swift), [LocalizationTests](Modules/Bookmarks/Tests/BookmarksPresentationTests/LocalizationTests.swift) |
| Bookmarks | BookmarksUI | 87% | [BookmarksViewSnapshotTests](Modules/Bookmarks/Tests/BookmarksUITests/Views/BookmarksViewSnapshotTests.swift), [LocalizationTests](Modules/Bookmarks/Tests/BookmarksUITests/LocalizationTests.swift) |
| Settings | SettingsFeature | 100% | covered through the Persistence and Presentation suites |
| Settings | SettingsPersistence | 99% | [LocalSettingsLoaderTests](Modules/Settings/Tests/SettingsPersistenceTests/Loaders/LocalSettingsLoaderTests.swift), [CodableSettingsStoreTests](Modules/Settings/Tests/SettingsPersistenceTests/Infrastructure/Codable/CodableSettingsStoreTests.swift), [InMemorySettingsStoreTests](Modules/Settings/Tests/SettingsPersistenceTests/Infrastructure/InMemory/InMemorySettingsStoreTests.swift) |
| Settings | SettingsPresentation | 100% | [SettingsViewModelTests](Modules/Settings/Tests/SettingsPresentationTests/ViewModels/SettingsViewModelTests.swift), [LocalizationTests](Modules/Settings/Tests/SettingsPresentationTests/LocalizationTests.swift) |
| Settings | SettingsUI | 89% | [SettingsViewSnapshotTests](Modules/Settings/Tests/SettingsUITests/Views/SettingsViewSnapshotTests.swift), [LocalizationTests](Modules/Settings/Tests/SettingsUITests/LocalizationTests.swift) |
| RemoteConfig | RemoteConfigFeature | 94% | covered through the API and Cache suites |
| RemoteConfig | RemoteConfigAPI | 100% | [RemoteBrandEndpointTests](Modules/RemoteConfig/Tests/RemoteConfigAPITests/Endpoints/RemoteBrandEndpointTests.swift), [RemoteBrandMapperTests](Modules/RemoteConfig/Tests/RemoteConfigAPITests/Mappers/RemoteBrandMapperTests.swift) |
| RemoteConfig | RemoteConfigCache | 89% | [LocalRemoteBrandLoaderTests](Modules/RemoteConfig/Tests/RemoteConfigCacheTests/Loaders/LocalRemoteBrandLoaderTests.swift), [CodableRemoteBrandStoreTests](Modules/RemoteConfig/Tests/RemoteConfigCacheTests/Infrastructure/Codable/CodableRemoteBrandStoreTests.swift) |
| Shared | SharedPresentation | 100% | [PriceFormatterTests](Modules/Shared/SharedPresentation/Tests/SharedPresentationTests/PriceFormatterTests.swift), [AddressFormatterTests](Modules/Shared/SharedPresentation/Tests/SharedPresentationTests/AddressFormatterTests.swift), [BundleLocalizedTests](Modules/Shared/SharedPresentation/Tests/SharedPresentationTests/BundleLocalizedTests.swift), [LocalizationTests](Modules/Shared/SharedPresentation/Tests/SharedPresentationTests/LocalizationTests.swift) |
| Shared | HTTPClientLive | 100% | [URLSessionHTTPClientTests](Modules/Shared/HTTPClient/Tests/HTTPClientLiveTests/URLSessionHTTPClientTests.swift) |
| Shared | DesignSystem | attributed to the UI targets | [TokensTests](Modules/Shared/DesignSystem/Tests/DesignSystemTests/TokensTests.swift), [LocalizationTests](Modules/Shared/DesignSystem/Tests/DesignSystemTests/LocalizationTests.swift) |
| Shared | TestSupport | not measured | [StubTests](Modules/Shared/TestSupport/Tests/TestSupportTests/StubTests.swift), [MemoryLeakTrackerTests](Modules/Shared/TestSupport/Tests/TestSupportTests/MemoryLeakTrackerTests.swift), [FixtureCoverageTests](Modules/Shared/TestSupport/Tests/TestSupportTests/FixtureCoverageTests.swift) |
| App | App root | 93% | [BrandSnapshotTests](PropertyListingsTests/Brand/BrandSnapshotTests.swift), [ListingsServiceTests](PropertyListingsTests/Composition/ListingsServiceTests.swift), [AppCompositionTests](PropertyListingsTests/Composition/AppCompositionTests.swift), [AppRouterTests](PropertyListingsTests/Composition/AppRouterTests.swift), [LocalizationTests](PropertyListingsTests/Resources/LocalizationTests.swift), [ListingsAcceptanceTests](PropertyListingsTests/Acceptance/ListingsAcceptanceTests.swift), [BookmarksAcceptanceTests](PropertyListingsTests/Acceptance/BookmarksAcceptanceTests.swift), [SettingsAcceptanceTests](PropertyListingsTests/Acceptance/SettingsAcceptanceTests.swift) |
| App | Separate process | not counted | [ListingsUITests](PropertyListingsUITests/ListingsUITests.swift), [BookmarksUITests](PropertyListingsUITests/BookmarksUITests.swift), [SettingsUITests](PropertyListingsUITests/SettingsUITests.swift), [ListingsAPIEndToEndTests](PropertyListingsEndToEndTests/ListingsAPIEndToEndTests.swift) |
| **Total Test Coverage** | | **93%** | |

## Listings

The Listings tab loads properties a page at a time, five for PropertyListings and four for Lakeside, since
the page size belongs to the brand. It shows each property as a card with its first image, title, price and
address, and keeps working offline from a cache whose age the brand also sets. Every state below is a
recorded snapshot from `ListingsViewSnapshotTests`, rendered on iPhone 17, iOS 26.

<table>
  <tr>
    <th colspan="2">Content</th>
    <th colspan="2">Loading</th>
    <th colspan="2">Loading more</th>
    <th colspan="2">Empty</th>
    <th colspan="2">Error</th>
  </tr>
  <tr>
    <td><a href="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/content.light.png"><img src="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/content.light.png" width="88" alt="Content, light"></a></td>
    <td><a href="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/content.dark.png"><img src="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/content.dark.png" width="88" alt="Content, dark"></a></td>
    <td><a href="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/loading.light.png"><img src="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/loading.light.png" width="88" alt="Loading, light"></a></td>
    <td><a href="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/loading.dark.png"><img src="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/loading.dark.png" width="88" alt="Loading, dark"></a></td>
    <td><a href="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/loadingMore.light.png"><img src="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/loadingMore.light.png" width="88" alt="Loading more, light"></a></td>
    <td><a href="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/loadingMore.dark.png"><img src="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/loadingMore.dark.png" width="88" alt="Loading more, dark"></a></td>
    <td><a href="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/empty.light.png"><img src="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/empty.light.png" width="88" alt="Empty, light"></a></td>
    <td><a href="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/empty.dark.png"><img src="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/empty.dark.png" width="88" alt="Empty, dark"></a></td>
    <td><a href="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/error.light.png"><img src="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/error.light.png" width="88" alt="Error, light"></a></td>
    <td><a href="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/error.dark.png"><img src="Modules/Listings/Tests/ListingsUITests/Views/__Snapshots__/ListingsViewSnapshotTests/error.dark.png" width="88" alt="Error, dark"></a></td>
  </tr>
</table>

Snapshot rows use no image URL, so the placeholder renders and nothing touches the network. The image
pipeline is exercised by the UI tests against the live endpoint.

### Data flow

One load online, then the same call offline. The request goes right, the data comes back left, and every type
change is a hop owned by exactly one layer.

<p align="center">
  <img alt="Listings data flow" src="docs/flow-listings.svg" width="900">
</p>

### Additional behaviours

1. **Spamming the like button is harmless.** Taps are debounced with an injected clock: the heart flips at once, the store is written once with the final state. Proven in `ListingsViewModelTests` with a `TestClock`.
2. **No duplicated load.** `load()` and `loadMore()` ignore a call while one is in flight, so Retry, pull to refresh and the two `.task` modifiers at appear cannot double a request. Proven in `ListingsViewModelTests` with a held spy.
3. **Pagination** fits the offset shape the mock response provides, `from`, `size`, `total` and `maxFrom`: five listings per request, the next five when the footer scrolls into view, and nothing above the root knows an offset exists.
4. **Languages come from the brand**: four for PropertyListings, the three main Swiss languages plus English, and two for Lakeside, English and Vietnamese. One catalog per module, with a test per module that fails on any missing key. The Settings tab switches between its brand's languages in place.

## Saved

The Saved tab lists every liked listing, newest first, from a JSON file on the device. A bookmark is a
snapshot taken at like time, so the tab works offline and a saved listing outlives the endpoint. Both
tabs observe one stream, so a like or a removal on either side shows on the other at once. Removing is
one intent, not a toggle: the row leaves at once, comes back with an alert if the write fails, and a
second tap during the write is ignored. There is no debounce, since there is nothing to undo.

<table>
  <tr>
    <th colspan="2">Content</th>
    <th colspan="2">Empty</th>
  </tr>
  <tr>
    <td><a href="Modules/Bookmarks/Tests/BookmarksUITests/Views/__Snapshots__/BookmarksViewSnapshotTests/content.light.png"><img src="Modules/Bookmarks/Tests/BookmarksUITests/Views/__Snapshots__/BookmarksViewSnapshotTests/content.light.png" width="150" alt="Saved content, light"></a></td>
    <td><a href="Modules/Bookmarks/Tests/BookmarksUITests/Views/__Snapshots__/BookmarksViewSnapshotTests/content.dark.png"><img src="Modules/Bookmarks/Tests/BookmarksUITests/Views/__Snapshots__/BookmarksViewSnapshotTests/content.dark.png" width="150" alt="Saved content, dark"></a></td>
    <td><a href="Modules/Bookmarks/Tests/BookmarksUITests/Views/__Snapshots__/BookmarksViewSnapshotTests/empty.light.png"><img src="Modules/Bookmarks/Tests/BookmarksUITests/Views/__Snapshots__/BookmarksViewSnapshotTests/empty.light.png" width="150" alt="Saved empty, light"></a></td>
    <td><a href="Modules/Bookmarks/Tests/BookmarksUITests/Views/__Snapshots__/BookmarksViewSnapshotTests/empty.dark.png"><img src="Modules/Bookmarks/Tests/BookmarksUITests/Views/__Snapshots__/BookmarksViewSnapshotTests/empty.dark.png" width="150" alt="Saved empty, dark"></a></td>
  </tr>
</table>

### Data flow

One like on the Listings tab, and how the Saved tab learns about it.

<p align="center">
  <img alt="Saved data flow" src="docs/flow-bookmarks.svg" width="900">
</p>

## Settings

The Settings tab holds two choices, appearance and language, saved in a JSON file beside the other two.
Appearance is System, Light or Dark and applies to every screen at once. Language is one of the languages
its brand ships, German, French, Italian or English for PropertyListings and English or Vietnamese for
Lakeside, each written in its own name, and applies without a relaunch: views resolve their strings against
the locale the root puts in the SwiftUI environment, and the view models are told the new locale and
rebuild their rows,
 so prices reformat and the loaded listings stay on screen. Both choices survive a relaunch, and a
choice that cannot be saved comes back with an alert.

<table>
  <tr>
    <th colspan="2">Settings</th>
    <th>French, dark chosen</th>
  </tr>
  <tr>
    <td><a href="Modules/Settings/Tests/SettingsUITests/Views/__Snapshots__/SettingsViewSnapshotTests/settings.light.png"><img src="Modules/Settings/Tests/SettingsUITests/Views/__Snapshots__/SettingsViewSnapshotTests/settings.light.png" width="150" alt="Settings, light"></a></td>
    <td><a href="Modules/Settings/Tests/SettingsUITests/Views/__Snapshots__/SettingsViewSnapshotTests/settings.dark.png"><img src="Modules/Settings/Tests/SettingsUITests/Views/__Snapshots__/SettingsViewSnapshotTests/settings.dark.png" width="150" alt="Settings, dark"></a></td>
    <td><a href="Modules/Settings/Tests/SettingsUITests/Views/__Snapshots__/SettingsViewSnapshotTests/settingsFrench.dark.png"><img src="Modules/Settings/Tests/SettingsUITests/Views/__Snapshots__/SettingsViewSnapshotTests/settingsFrench.dark.png" width="150" alt="Settings in French with dark chosen"></a></td>
  </tr>
</table>

### Data flow

One language pick, and how every tab follows it without a relaunch.

<p align="center">
  <img alt="Settings data flow" src="docs/flow-settings.svg" width="900">
</p>

## Run the app

Everything opens from the workspace, never from the project.

```bash
git clone git@github.com:anthony1810/PropertyListings.git
cd PropertyListings
open PropertyListings.xcworkspace
```

Select a brand scheme, `PropertyListings` or `Lakeside`, and the **iPhone 17** simulator (iOS 26), then Run.
The two schemes install as two separate apps, so both brands can sit on the same simulator at once. Any
iOS 18.0 or later simulator works for the app itself; iPhone 17 is the one the snapshot tests are recorded on.

## Run the tests

### In Xcode

| What | Scheme | Destination | Then |
|---|---|---|---|
| App unit tests, acceptance tests and UI tests | `PropertyListings` or `Lakeside` | iPhone 17, iOS 26 | Cmd+U |
| One package, all its targets | `Listings-Package`, `Bookmarks-Package`, `Settings-Package`, `RemoteConfig-Package`, `SharedPresentation-Package`, `DesignSystem-Package` | iPhone 17, iOS 26 | Cmd+U |
| Packages with no UI or catalog | `HTTPClient-Package`, `TestSupport-Package` | My Mac | Cmd+U |
| End to end against the live endpoint | `PropertyListingsEndToEndTests` | My Mac | Cmd+U |

The scheme picker lists the package schemes under the workspace; pick one and the test navigator shows its
targets. Use **iPhone 17, iOS 26** for anything with a snapshot test, because the references were recorded
there and another device or OS renders differently and fails the comparison.

The same app suite runs under either brand scheme. `BrandSnapshotTests` compares against the reference
folder named for whichever brand is hosting it, so a change that affects one brand only is still visible
in review.

To re-record snapshots after an approved UI change: Product, Scheme, Edit Scheme, Test, Arguments, add the
environment variable `SNAPSHOT_RECORD` with value `1`, run the tests once, remove the variable, run them
again, and commit the new images under `__Snapshots__`.

## License

MIT
