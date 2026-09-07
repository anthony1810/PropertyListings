# Listings and Saved: design brief

## References studied

Property and marketplace apps converge on the same card, and the reasons are worth naming:

- **Airbnb, Zillow, Redfin**: a full-bleed photo carries the card. The heart sits on the photo at the
  top trailing corner so it never competes with the text. Price is the boldest text, placed where the eye
  lands first. Address and secondary facts are one quiet line.
- **Swiss portals** (Homegate, ImmoScout24, newhome): the price appears as a tag on or directly under the
  photo, the address carries postal code and locality, and "Merken" (save) is the favourite verb, which is
  why the like button's German strings say Merken / Gemerkt.
- **Favourites tabs** across these apps reuse the exact same card with the heart filled. Removal is the
  heart tap plus a swipe, and the empty state carries one call to action back to browsing.
- General card practice ([Mobbin real estate](https://mobbin.com/explore/mobile/app-categories/real-estate),
  [Eleken card UI](https://www.eleken.co/blog-posts/card-ui-examples-and-best-practices-for-product-owners),
  [2025 trends](https://medium.com/@emilyanderson51691/top-12-ux-ui-design-trends-for-real-estate-apps-in-2025-37a5b70aef21)):
  large imagery, generous whitespace, one primary action per card, subtle motion, and states designed
  rather than improvised.

## Decisions for PropertyListings

| Element | Decision | Why |
|---|---|---|
| Card image | Full-bleed, 3:2, continuous 20 pt corners | Photos sell property; 3:2 matches the source images without cropping faces |
| Price | Capsule tag on the photo, bottom leading, bold rounded type | First thing read; the tag keeps it legible over any photo |
| Like | Heart on the photo, top trailing, on a thin material disc | Airbnb convention; the disc keeps it visible on light and dark photos |
| Title | Two lines max, headline rounded semibold | Titles run long in German and French |
| Address | One line, pin glyph, secondary colour | Supporting fact, never competes with the price |
| List | Single column, 16 pt gutters, 8 pt between cards | Nine listings; a grid would shrink the photos that sell |
| Loading | Three shimmering skeleton cards | Shape of the content, no spinner |
| Empty (Listings) | House glyph, "No listings yet", pull to refresh hint | Only reachable if the API returns zero |
| Error | Wi-Fi glyph, message, prominent Retry | The one state with an action |
| Saved | Same card, heart filled, newest first, swipe to remove | Reuse; the heart is the removal affordance users already know |
| Empty (Saved) | Heart glyph, hint, "Browse listings" button | One call to action back to the Listings tab |
| Tab bar | Listings (house), Saved (heart) | System tab bar; iOS 26 renders it in Liquid Glass |
| Dark mode | Same tokens; elevated surfaces instead of shadows | Shadows disappear on dark grounds |
| Type | Inter in Figma as the SF Pro stand-in, SF Pro in the app | Figma servers cannot render SF Pro; spacing and weights match, letterforms differ |

## Out of scope

Detail screen, filters, map, sorting, Romansh.
