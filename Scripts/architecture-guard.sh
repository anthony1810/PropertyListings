#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
fail=0
say() { echo "error: guard: $1"; fail=1; }
sources() { grep -rlE "$1" "${@:2}" --include='*.swift' --exclude-dir=.build 2>/dev/null | grep -v '/Tests/' || true; }

# 1. SwiftUI and UIKit only in the UI targets and the app
bad=$(sources '^import (SwiftUI|UIKit)$' Modules | grep -vE '/Sources/(ListingsUI|BookmarksUI|DesignSystem|TestSupport)/' || true)
[ -z "$bad" ] || say "SwiftUI/UIKit outside the UI targets: $bad"

# 2. No import between the verticals
for vertical in Listings Bookmarks Settings; do
  for other in Listings Bookmarks Settings; do
    [ "$vertical" = "$other" ] && continue
    [ -z "$(sources "^import $other" "Modules/$vertical")" ] || say "$vertical imports $other"
  done
done

# 3. Kingfisher only inside DesignSystem
bad=$(sources '^import Kingfisher' Modules PropertyListings | grep -v 'Modules/Shared/DesignSystem/Sources/' || true)
[ -z "$bad" ] || say "Kingfisher imported outside DesignSystem: $bad"

# 4. The HTTPClient seam is imported by the root and its own live module only, never by a feature
bad=$(sources '^import HTTPClient$' Modules | grep -v 'Modules/Shared/HTTPClient/Sources/' || true)
[ -z "$bad" ] || say "HTTPClient imported inside a feature module: $bad"

# 5. The host is named once in sources, plus the end-to-end test
hosts=$(grep -rl 'apiary-mock' Modules PropertyListings PropertyListingsEndToEndTests --include='*.swift' --exclude-dir=.build 2>/dev/null | sort || true)
allowed=$'PropertyListings/Configuration/ServiceURLs.swift\nPropertyListingsEndToEndTests/ListingsAPIEndToEndTests.swift'
for h in $hosts; do
  grep -qx "$h" <<< "$allowed" || say "host named outside ServiceURLs + end-to-end test: $h"
done

# 6. Test support modules are linked by test bundles only
bad=$(sources '^import [A-Za-z]*TestSupport$' Modules PropertyListings | grep -v '/Sources/[A-Za-z]*TestSupport/' || true)
[ -z "$bad" ] || say "test support imported by production code: $bad"

# 7. Cache and API never meet
[ -z "$(sources '^import ListingsAPI'   Modules/Listings/Sources/ListingsCache)" ] || say "ListingsCache imports ListingsAPI"
[ -z "$(sources '^import ListingsCache' Modules/Listings/Sources/ListingsAPI)"   ] || say "ListingsAPI imports ListingsCache"

[ $fail -eq 0 ] && echo "guard: ok"
exit $fail
