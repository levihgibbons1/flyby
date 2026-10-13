# Spec: Visibility & location privacy (v0.3, provisional)

References: `png/14-privacy-owner-vs-shared.png`, `png/19-settings-privacy-about.png`, `png/07`, `png/08`

## Visibility
- `FlightVisibility` = `private` (default) | `followers` | `public`. This is the default in the model initializer, in the Log form, and later as the DB column default.
- Shown on **every** flight card, on Flight Detail, and in the Journal summary ("Only you"). Changing it uses `.symbolEffect(.replace)` plus a selection haptic.

## Home airport: one global setting (F11)
- **Profile → Settings → Privacy → "Hide home airport"**, a single global boolean, **On by default** (privacy-first; sharing the home airport is opt-in). Stored on the profile (`profiles.hide_home_airport boolean not null default true`). id `settings.hideHome`.
- Also in Settings: Home airport (precise, never displayed to others; "only you"), Default visibility (Private), Default trim (1.0 nm). The public profile shows a region only ("Home base: Bay Area").
- **Precedence:** per-share override → per-flight override → global setting.

| Level | Where | Stored? | Initial value |
|---|---|---|---|
| Global | Settings → Privacy | profile | **On** |
| Per flight (optional; may be omitted in Sprint 1) | Log a Flight → "Privacy when shared" | `flights.hide_home_override` (nullable; `null` = follow global) | `null` (shows the global value + "Your default…" caption) |
| Per share | Share Recap toggles | **not persisted** (applies to this export only) | the effective flight value |

- Turning the toggle off in Share **doesn't** change the flight or the global setting, and the next share starts from the default again. A flight override only changes that flight.
- Changing the global setting re-renders cached shared geometry for flights that have `null` overrides.

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
- **Later:** shared geometry is stored separately, with RLS so only the owner can read the precise `tracks` rows.
- The owner's own Flight Detail shows the full track, with the privacy zone ring as a preview.
