# Design system

Figma: [PropertyListings](https://www.figma.com/design/mGYnBSubQuhnIJkenp8aMC), three pages: Foundations,
Components, Screens. Every variable's iOS code syntax is the Swift name, so the file and the
`DesignSystem` package share one vocabulary. Inter stands in for SF Pro in Figma: spacing and weights
match, letterforms differ.

![Foundations](foundations.png)

## Tokens

| Figma variable | Light | Dark | Swift |
|---|---|---|---|
| `color/surface` | #FFFFFF | #121417 | `DSColor.surface` |
| `color/surfaceElevated` | #F2F3F6 | #1C2027 | `DSColor.surfaceElevated` |
| `color/textPrimary` | #171B24 | #E7EAF0 | `DSColor.textPrimary` |
| `color/textSecondary` | #626B7A | #97A0B0 | `DSColor.textSecondary` |
| `color/accent` | #2946C4 | #8EA3FF | `DSColor.accent` |
| `color/like` | #D83A56 | #FF6B81 | `DSColor.like` |
| `color/onImage` | #FFFFFF | #FFFFFF | `DSColor.onImage` |

| Figma variable | Value | Swift |
|---|---|---|
| `spacing/xs` `s` `m` `l` `xl` | 4, 8, 16, 24, 32 | `DSSpacing.*` |
| `radius/m` `l` | 12, 20 | `DSRadius.*` |

| Text style | Inter | Swift |
|---|---|---|
| `DSFont/largeTitle` | Bold 34/41 | navigation title |
| `DSFont/title` | Semi Bold 17/22 | `DSFont.title` |
| `DSFont/price` | Bold 15/20 | `DSFont.price` |
| `DSFont/body` | Regular 17/22 | body |
| `DSFont/caption` | Regular 13/18 | `DSFont.caption` |
| `DSFont/tab` | Medium 10/12 | tab bar labels |

The v1 values in `Colors.xcassets` are the same numbers. Phase 6 copies any change made in Figma back
into the asset catalog; names never change.

## Components

![ListingCard](listing-card.png)

| Figma component | Variants | Swift |
|---|---|---|
| `ListingCard` | Default, Liked, ImageFailed | `ListingCard(model:likeIdentifier:onLike:)` |
| `LikeButton` | Off, On | `LikeButton(isOn:action:)` |
| `PriceTag` | Amount, OnRequest | inside `ListingCard`, text from `PriceFormatter` |
| `StateView` | Empty, Error | `EmptyStateView`, `ErrorStateView` |
| `SkeletonRow` | one | `SkeletonRow().shimmering()` |
| `TabBar` | Listings, Saved, Settings | `TabView` in `RootView`, driven by `AppRouter` |

Card anatomy: 3:2 image with `radius/l` corners, `PriceTag` bottom leading, `LikeButton` top trailing on a
thin material disc, title on two lines in `DSFont/title`, address on one line with a pin in `DSFont/caption`.

## Brand

![Brand](brand.png)

| Asset | Figma | Xcode |
|---|---|---|
| App icon | `Brand / App icon / 1024`, a flat square, iOS applies the mask | `AppIcon.appiconset`, one 1024 image with no alpha |
| Launch screen | `Brand / Launch / Light` and `Launch / Dark`, `color/surface` with the mark in `color/accent` | `UILaunchScreen` with `LaunchBackground` and `LaunchMark`, both with a dark appearance |
| Accent | `color/accent` | `AccentColor` |

The mark is `house-fill` from [Phosphor Icons](https://phosphoricons.com), MIT licensed. It ships as an SVG
asset with its vector representation preserved, so the launch screen renders it at any scale.

## Screens

Listings: content, loading, empty, error. Saved: content, empty. Settings: one screen, an appearance
segmented control (System, Light, Dark) over `surfaceElevated` and a grouped language list with the
languages in their own names and a checkmark in `accent` on the chosen one. Each in light and dark,
iPhone 17 frame.

![Light](screens-light.png)
![Dark](screens-dark.png)

## What the code does that Figma cannot show

The shimmer sweep on `SkeletonRow`, the heart's symbol transition and haptic, the fade-in of a loaded
image, pull to refresh, and the Liquid Glass tab bar on iOS 26. The Figma tab bar is the iOS 18 look.
