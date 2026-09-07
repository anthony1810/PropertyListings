# Bookmarks Feature Specs

## Story: Customer bookmarks listings they like

### Narrative #1

> As a customer browsing listings
> I want to like a listing with one tap
> So I can find it again later

#### Scenarios (acceptance criteria)

```
Given a listing on the Listings tab that is not liked
 When the customer taps its heart
 Then the heart fills immediately
  And the listing is saved on the device
  And the listing appears on the Saved tab
```

```
Given a liked listing
 When the customer kills the app and launches it again
 Then the heart is still filled
  And the listing is still on the Saved tab
```

```
Given a liked listing on the Listings tab
 When the customer taps its heart again
 Then the heart clears immediately
  And the listing leaves the Saved tab
```

```
Given a listing whose like cannot be saved to the device
 When the customer taps its heart
 Then the heart reverts to its previous state
  And a message explains that the change could not be saved
```

### Narrative #2

> As a customer with liked listings
> I want to see everything I liked in one place
> So I can compare them

#### Scenarios (acceptance criteria)

```
Given the customer has liked listings
 When the customer opens the Saved tab
 Then the app lists every liked listing, newest first
  And each row shows the image, the title, the price and the address as saved at like time
  And this works without connectivity
```

```
Given the customer has no liked listings
 When the customer opens the Saved tab
 Then the app shows an empty state with a hint to like a listing
```

### Narrative #3

> As a customer on the Saved tab
> I want to remove a listing I no longer care about
> So the tab stays useful

#### Scenarios (acceptance criteria)

```
Given a listing on the Saved tab
 When the customer taps its heart or swipes to remove
 Then the row leaves the Saved tab immediately
  And the listing's heart on the Listings tab clears
```

```
Given a listing on the Saved tab whose removal cannot be saved to the device
 When the customer removes it
 Then the row comes back
  And a message explains that the change could not be saved
```

## Use cases

### Save Bookmark

Data: bookmark (a snapshot of the listing: id, title, price, address, image URL, saved-at date)

Primary course:
1. Execute "Save Bookmark" with the bookmark.
2. System replaces any bookmark with the same id.
3. System writes the bookmarks to the device.
4. System notifies observers with the new list.
5. System delivers success.

Saving error course (sad path):
1. System delivers the error.

### Remove Bookmark

Data: bookmark id

Primary course:
1. Execute "Remove Bookmark" with the id.
2. System removes the bookmark with that id.
3. System writes the bookmarks to the device.
4. System notifies observers with the new list.
5. System delivers success.

Saving error course (sad path):
1. System delivers the error.

### Load Bookmarks

Primary course:
1. Execute "Load Bookmarks".
2. System reads the bookmarks from the device.
3. System delivers the bookmarks.

Empty course:
1. System delivers an empty list.

Corrupt data course (sad path):
1. System delivers the error.

### Observe Bookmarks

Primary course:
1. Execute "Observe Bookmarks".
2. System delivers the current bookmarks immediately.
3. System delivers the full list again after every save or remove, until the observer stops.

## Model specs

### Bookmark

| Property | Type | Notes |
|---|---|---|
| `id` | `String` | the listing id |
| `title` | `String` | as saved at like time |
| `price` | `Price?` | amount and currency, as saved |
| `address` | `Address` | `street?`, `postalCode?`, `locality`, as saved |
| `imageURL` | `URL?` | as saved |
| `savedAt` | `Date` | orders the Saved tab, newest first |

A bookmark is a snapshot. It is its own type, not the listings model: it outlives the listing on
the API and may diverge from it. The composition root maps one to the other.

## Scenario to test map

Acceptance tests live in `PropertyListingsTests/BookmarksAcceptanceTests.swift`, one per scenario,
grouped by narrative. Both tabs run over one in-memory store through the real composition; a
relaunch is a second composition over the same store.

| Scenario | Proven by |
|---|---|
| Tap fills the heart, saves, appears on Saved | `customerTapsHeart_heartFillsAndListingAppearsOnSaved` · Maestro `03-saved-tab-shows-and-unbookmarks` |
| Like survives kill and relaunch | `customerKillsAndRelaunches_likeIsStillThere` · Maestro `02-like-persists-across-relaunch` |
| Tap again clears and leaves Saved | `customerTapsHeartAgain_heartClearsAndListingLeavesSaved` |
| Save failure reverts with a message | `savingFails_heartRevertsWithAMessage` |
| Saved lists everything newest first, offline | `customerOpensSaved_seesEveryLikeNewestFirst_withoutConnectivity` · snapshot `content` |
| Saved empty state | `customerOpensSaved_withNoLikes_seesNothingToShow` · snapshot `empty` |
| Remove on Saved clears the heart on Listings | `customerRemovesOnSaved_rowLeavesAndHeartClearsOnListings` · Maestro `03-saved-tab-shows-and-unbookmarks` |
| Remove failure brings the row back | `removingFails_rowComesBackWithAMessage` |
