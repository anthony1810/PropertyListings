# Listings Feature Specs

## Requirements from the brief

| Brief | Requirement | Where it is covered |
|---|---|---|
| Task 1 | Display a list of real estate listings from `GET /properties` | Narrative #1, scenario 1 |
| Task 1 | Each item shows the first image, the title, the price and the address | Narrative #1, scenario 1 |
| Task 1 | Layout is free | Design brief and Figma file |
| Remarks | Compiles and runs on iOS 18.0 with Xcode 26, SwiftUI for the UI | Project settings, CI |

Scenarios are tagged **Brief** when the brief asks for them and **Addition** when they are ours.

## Story: Customer requests to see property listings

### Narrative #1

> As an online customer
> I want the app to load the latest property listings
> So I can see what is on the market

#### Scenarios (acceptance criteria)

**Brief, Task 1.**

```
Given the customer has connectivity
 When the customer opens the Listings tab
 Then the app displays the latest listings from remote
  And each row shows the first image, the title, the price and the address
  And the app replaces the cache with the new listings
```

**Addition.** The payload has listings without a price.

```
Given the customer has connectivity
  And a listing has no price
 When the listings are displayed
 Then that row shows "Price on request"
```

**Addition.** The payload has listings without a street.

```
Given the customer has connectivity
  And a listing has no street
 When the listings are displayed
 Then that row shows the postal code and locality only
```

**Addition.** Error handling.

```
Given the customer has connectivity
  And the remote responds with anything other than 200 or with malformed data
  And there is no valid cache
 When the customer opens the Listings tab
 Then the app shows an error state with a Retry action
```

### Narrative #2

> As an offline customer
> I want the app to show the latest saved listings
> So I can keep browsing without a connection

#### Scenarios (acceptance criteria)

**Addition.** Offline support.

```
Given the customer has no connectivity
  And there is a cached version of the listings
  And the cache is less than seven days old
 When the customer opens the Listings tab
 Then the app displays the cached listings
```

**Addition.**

```
Given the customer has no connectivity
  And there is a cached version of the listings
  And the cache is seven days old or more
 When the customer opens the Listings tab
 Then the app shows an error state with a Retry action
```

**Addition.**

```
Given the customer has no connectivity
  And the cache is empty
 When the customer opens the Listings tab
 Then the app shows an error state with a Retry action
```

**Addition.**

```
Given the app launches
  And the cache is seven days old or more
 When the launch completes
 Then the expired cache is deleted
```

## Use cases

### Load Listings From Remote

Data: URL

Primary course (happy path):
1. Execute "Load Listings" with the URL.
2. System downloads data from the URL.
3. System validates the downloaded data.
4. System creates listings from valid data.
5. System delivers the listings.

Invalid data course (sad path):
1. System delivers an invalid data error.

No connectivity course (sad path):
1. System delivers a connectivity error.

### Load Listings From Cache

Data: max cache age (seven days)

Primary course:
1. Execute "Load Listings" with the max age.
2. System retrieves the cached listings and their timestamp.
3. System validates the cache is less than seven days old.
4. System delivers the cached listings.

Retrieval error course (sad path):
1. System delivers the error.

Expired cache course (sad path):
1. System delivers a cache-miss error.

Empty cache course (sad path):
1. System delivers a cache-miss error.

### Validate Listings Cache

Primary course:
1. Execute "Validate Cache".
2. System retrieves the cached listings and their timestamp.
3. System validates the cache is less than seven days old.

Retrieval error course (sad path):
1. System deletes the cache.

Expired cache course (sad path):
1. System deletes the cache.

### Cache Listings

Data: listings

Primary course:
1. Execute "Save Listings" with the listings.
2. System deletes the old cache.
3. System encodes the listings.
4. System timestamps the new cache.
5. System saves the new cache.
6. System delivers success.

Deleting error course (sad path):
1. System delivers the error.

Saving error course (sad path):
1. System delivers the error.

## Model specs

### Listing

| Property | Type | Notes |
|---|---|---|
| `id` | `String` | from `results[].id` |
| `title` | `String` | from `localization.<primary>.text.title`; required |
| `price` | `Price?` | `buy.price` or `rent.price` with `prices.currency`; nil when absent |
| `address` | `Address` | `street?`, `postalCode?`, `locality` |
| `imageURL` | `URL?` | the first attachment of type `IMAGE`; nil when none |

### Payload contract

```
GET /properties

200 RESPONSE

{
  "from": 0, "size": 100, "total": 9, "maxFrom": 0,
  "results": [
    {
      "id": "a string",
      "listing": {
        "prices": { "currency": "CHF", "buy": { "price": 9999999 }, "rent": {} },
        "address": { "street": "optional", "postalCode": "2406", "locality": "La Brévine" },
        "localization": {
          "primary": "de",
          "de": {
            "attachments": [ { "type": "IMAGE" | "DOCUMENT", "url": "https://…" } ],
            "text": { "title": "a title" }
          }
        }
      }
    }
  ]
}
```

## Scenario to test map

Acceptance tests live in `PropertyListingsTests/ListingsAcceptanceTests.swift`, one per scenario,
grouped by narrative, driving the real composition with stubs at the edges.

| Scenario | Proven by |
|---|---|
| Online, latest listings displayed and cached | `customerOpensListings_seesLatestListingsFromRemote` · `ListingsServiceTests.load_deliversRemoteListingsAndCachesThem_whenOnline` · Maestro `01-list-shows-listings` |
| No price shows "Price on request" | `customerOpensListings_listingWithoutPrice_seesPriceOnRequest` · snapshot `content` |
| No street shows postal code and locality | `customerOpensListings_listingWithoutStreet_seesPostalCodeAndLocalityOnly` · snapshot `content` |
| Non-200 or malformed, no cache, error with Retry | `customerOpensListings_remoteFailsAndNoCache_seesErrorWithRetry` (parametrised) · `customerRetriesAfterAFailure_seesListings` · snapshot `error` |
| Offline, fresh cache displayed | `offlineCustomer_seesCachedListings_whenCacheIsFresh` · manual airplane-mode check |
| Offline, expired cache, error with Retry | `offlineCustomer_seesErrorWithRetry_whenCacheIsSevenDaysOld` |
| Offline, empty cache, error with Retry | `offlineCustomer_seesErrorWithRetry_whenCacheIsEmpty` |
| Launch deletes an expired cache | `appLaunch_deletesExpiredCache` |
