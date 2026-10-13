# Spec: Visibility & location privacy (provisional)

Reference: `png/14-privacy-owner-vs-shared.png`

## Visibility
- `FlightVisibility` = `private` (default) | `followers` | `public`. This is the default in the model initializer, in the Log form, and later as the DB column default.
- Shown on **every** flight card, on Flight Detail, and in the Journal summary ("Only you"). Changing it uses `.symbolEffect(.replace)` plus a selection haptic.

## Home airport & track trimming
- Profile setting: Home airport (precise; never displayed to others). Public profile shows a region only ("Home base: Bay Area").
- For any non-owner view, recap, or share: if DEP or ARR matches the home airport,
  - replace the ICAO/name with a region label ("BAY AREA") and a `shield` note ("Home field hidden"),
  - remove the endpoint marker (no start dot),
  - trim the first/last **1.0 nm** of track (user-adjustable),
  - fade the route to 0% alpha over the privacy radius (~1.5× the trim distance), using a radial mask on the route layer only. The mask center is offset by a random amount fixed **per pilot**, so it can't be averaged across shares,
  - fit the camera or snapshot region to the trimmed geometry, and draw **no** zone ring or disc in shared views (a ring would point at the field). See `maps.md`.
- Tracks too short to trim: hide both endpoints and show "Track too short to trim; endpoints hidden."
- Tail number: hidden on shares by default ("Tail hidden" / omitted). Exact times: off by default (date only).
- Sprint 1: on-device `TrackPrivacy.trim(_:distance:)` / `hideHomeAirport`. Later: shared geometry stored separately, with RLS so only the owner can read the precise `tracks` rows.
- The owner's own Flight Detail shows the full track, with the privacy zone ring as a preview.
