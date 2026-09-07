# PropertyListings

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![iOS](https://img.shields.io/badge/iOS-18.0-blue.svg)
![Xcode](https://img.shields.io/badge/Xcode-26-blue.svg)
[![Tests](https://github.com/anthony1810/PropertyListings/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/anthony1810/PropertyListings/actions/workflows/tests.yml)

A SwiftUI app that lists real estate from a REST endpoint and lets you bookmark listings on the device.
Two tabs: Listings and Saved. iOS 18.0, Xcode 26, Swift 6.

> Work in progress. Features land on `main` through one branch and one pull request each. See the status table.

## Architecture

Horizontal layers inside vertical feature slices. Each feature is one Swift package with UI, Presentation,
Feature and data targets. Shared modules carry implementation only. The app target is the composition root,
the only place concrete types meet.

<p align="center">
  <img alt="PropertyListings architecture overview" src="docs/architecture-overview.svg" width="900">
</p>

## Module map

```
PropertyListings.xcworkspace
├── PropertyListings.xcodeproj
│   ├── PropertyListings/
│   │   ├── PropertyListingsApp.swift
│   │   ├── Composition/
│   │   │   ├── ListingsService.swift
│   │   │   ├── AppComposition.swift
│   │   │   └── AppComposition+Root.swift
│   │   └── Configuration/
│   │       └── ServiceURLs.swift
│   ├── PropertyListingsTests/
│   └── PropertyListingsEndToEndTests/
├── maestro/
├── docs/
└── Modules/
    ├── Shared/
    │   ├── HTTPClient/
    │   ├── SharedPresentation/
    │   ├── DesignSystem/
    │   └── TestSupport/
    ├── Listings/
    │   ├── Sources/ListingsFeature/
    │   ├── Sources/ListingsAPI/
    │   ├── Sources/ListingsCache/
    │   ├── Sources/ListingsPresentation/
    │   ├── Sources/ListingsUI/
    │   └── Tests/
    └── Bookmarks/
        ├── Sources/BookmarksFeature/
        ├── Sources/BookmarksPersistence/
        ├── Sources/BookmarksPresentation/
        ├── Sources/BookmarksUI/
        └── Tests/
```

Feature specs, in the Essential Developer format: [Listings](docs/specs/listings.md), [Bookmarks](docs/specs/bookmarks.md).
The detailed diagram with every type: [docs/architecture.html](docs/architecture.html).

## Status

| Feature | Branch | State |
|---|---|---|
| Skeleton, shared modules, CI | `main` | in progress |
| Listings | `feature/listings` | planned |
| Bookmarks and the Saved tab | `feature/bookmarks` | planned |

## Getting started

```bash
git clone git@github.com:anthony1810/PropertyListings.git
cd PropertyListings
open PropertyListings.xcworkspace
```

Select the `PropertyListings` scheme and any iOS 18 or later simulator.

## Testing

```bash
swift test --package-path Modules/Shared/TestSupport
Scripts/architecture-guard.sh
```

## License

MIT
