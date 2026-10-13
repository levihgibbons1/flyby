# Spec: Visibility & location privacy (v0.3.1, provisional)

References: `png/14-privacy-owner-vs-shared.png`, `png/19-settings-privacy-about.png`, `png/07`, `png/08`

## Visibility
- `FlightVisibility` = `private` (default) | `followers` | `public`. This is the default in the model initializer and in the Log form. *(Future, not Sprint 1: also the DB column default.)*
- Shown on **every** flight card, on Flight Detail, and in the Journal summary ("Only you"). Changing it uses `.symbolEffect(.replace)` plus a selection haptic.

## Home airport: one global setting (F11)
- **Profile → Settings → Privacy → "Hide home airport"**, a single global boolean, **On by default** (privacy-first; sharing the home airport is opt-in). id `settings.hideHome`.
  - **Sprint 1 (mock-only):** stored in the in-memory/mock `ProfileStore` as `hideHomeAirport: Bool = true`. It's covered by `PrivacySettingsTests` (the default is `true`; a share override doesn't mutate it).
  - *Future (Supabase schema PR, not Sprint 1):* `profiles.hide_home_airport boolean not null default true`, plus a migration test asserting `default true`.
- Also in Settings: Home airport (precise, never displayed to others; "only you"), Default visibility (Private), Default trim (1.0 nm). The public profile shows a region only ("Home base: Bay Area").
- **Precedence (Sprint 1):** per-share override → global setting. A per-flight override is **deferred** (PM scope trim) and would slot in between later.

| Level | Where | Stored? | Initial value |
|---|---|---|---|
| Global | Settings → Privacy | profile | **On** |
| ~~Per flight~~ **Deferred past Sprint 1** | Log a Flight shows a read-only note instead ("Home airport hidden when shared · from your privacy setting") | *Future:* `flights.hide_home_override` (nullable; `null` = follow global) | — |
| Per share | Share Recap toggles | **not persisted** (applies to this export only) | the global value |

- Turning the toggle off in Share **doesn't** change the global setting, and the next share starts from the default again.
- Changing the global setting invalidates cached shared snapshots (cache key includes the effective setting).

## Track trimming and home hiding (applied to every non-owner view, recap and share)
If DEP or ARR matches the home airport and the effective "Hide home airport" is On:
- replace the ICAO/name with a region label ("BAY AREA") and a `shield` note ("Home field hidden"),
- remove the endpoint marker (no start dot),
- trim the first/last **1.0 nm** of the *validated* track (user-adjustable),
- fade the route to 0% alpha over the privacy radius (~1.5× the trim distance), using a radial mask on the route layer only. The mask center is offset by a random amount fixed **per pilot**, so it can't be averaged across shares,
- fit the camera or snapshot region to the trimmed geometry, and draw **no** zone ring or disc in shared views (a ring would point at the field). See `maps.md`.

Edge cases:
- Tracks too short to trim (< 2 points left after trimming): hide both endpoints and show "Track too short to trim; endpoints hidden." There's no map card in recaps.
- An approximate route (no track) to or from home: the line starts at the region-label position, not at the field.
- Tail number is hidden on shares by default ("Tail hidden" / omitted). Exact times are off by default (date only).

Implementation:
- **Sprint 1:** on-device `TrackPrivacy.trim(_:distance:)` / `hideHomeAirport` after `TrackGeometry.validated`.
- *Future (not Sprint 1):* shared geometry is stored separately, with RLS so only the owner can read the precise `tracks` rows.
- The owner's own Flight Detail shows the full track, with the privacy zone ring as a preview.
