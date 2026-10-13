# QA cross-check: Skyglass design specs vs Sprint 1 QA plan

Date: Oct 13, 2026 (PT) · Reviewer: Flyby QA · Type: read-only document review. **No tests were executed, and no build or simulator was run.**
Inputs: `design/DESIGN_SYSTEM.md` (v0.2.1), `design/specs/*.md` (including `maps.md`), `design/proposal.html`, `design/png/01–14` (filenames and inventory only; I did not inspect the pixels in detail) vs `sprint1-acceptance-criteria.md` and `MVP-PLAN.md`.
Decisions in effect: minimum iOS 17. Home airport sharing is optional and off by default, so "Hide home airport" is ON by default (low priority for Sprint 1).

## Confirmed consistent (code review)
- The not-for-navigation disclaimer is on Flight Detail (flight-detail.md), the Log save footer, and every recap template (recaps.md rule 6). It's real text, not a modal.
- Visibility defaults to Private in the model, the Log form and the DB default (privacy-sharing.md, log-flight.md, DESIGN_SYSTEM §6 VisibilityPicker).
- Share defaults: Hide home airport and Trim are ON (recaps.md rule 1 = AC6.4). Tail number and exact times are off by default.
- Tab order, symbols and ids `tab.home…tab.profile` match AC2.4.
- "Approximate route" fallback matches AC4.3. MKMapSnapshotter is used for lists (AC4.5). There are no compass, user-location or recenter controls, and no Marker balloons.
- Reduce Motion is specified in motion.md (cross-fade, pre-drawn route). Reduce Transparency and Increase Contrast are covered for glass.

## Findings

### F1. Liquid Glass / iOS 26-only APIs conflict with the iOS 17 minimum
- Label: code review finding · **Severity: Critical** (the build won't compile or deploy to iOS 17 as specified)
- File/section: DESIGN_SYSTEM.md §1, §2, §5, §6; navigation.md "Behavior"; motion.md (Glass morph, Card→Detail, Tab bar minimize); flight-detail.md "Glass controls"; proposal.html ("iOS 26", 8 mentions)
- Issue: `.glassEffect`, `GlassEffectContainer`, `glassEffectID`, `.buttonStyle(.glass/.glassProminent)` and `.tabBarMinimizeBehavior` are iOS 26 APIs. `Tab(...)` in TabView and `.navigationTransition(.zoom)`/`.matchedTransitionSource` are iOS 18. MVP-PLAN and AC S1 require iOS 17.0.
- Fix: add a "Platform fallback" section. Gate these with `if #available(iOS 26, *)` (and iOS 18), with iOS 17 fallbacks: `.ultraThinMaterial`/solid `surface` and `.bordered` buttons, the `.tabItem` TabView, and the standard push transition. Define these as reusable modifiers in `DesignSystem/` (for example `flybyGlass()`) so feature views never call the iOS 26 APIs directly. QA will add AC: build and run on an iOS 17 simulator runtime.

### F2. Map code force-unwraps the track (crash on empty or missing GPS)
- Label: code review finding · **Severity: High**
- File/section: specs/maps.md "MapKit implementation" (`track.first!`, `track.last!`)
- Issue: a flight with an empty, 1-point or nil track crashes. The spec handles "no track" only as a rendering fallback, and doesn't guard the code path.
- Fix: branch on `track.count >= 2`. Otherwise use the Approximate-route path, and if the airports are unknown too, show a map placeholder ("Route unavailable"). No `!` on geometry. Add unit tests for 0, 1, 2 and 500+ points.

### F3. No handling for invalid coordinates or the antimeridian
- Label: code review finding · **Severity: High**
- File/section: specs/maps.md (Camera `.rect` fit, `region(fitting:)`, great-circle fallback); flight-detail.md
- Issue: the specs don't cover out-of-range lat/lon, NaN, (0,0) "null island" points, duplicate points, or tracks crossing ±180°. A naive bounding rect around a dateline crossing spans the whole globe, and the great-circle line can wrap the wrong way.
- Fix: add a "Geometry validation" section. Drop points with |lat|>90, |lon|>180, NaN, or (0,0). Split polylines at the antimeridian, and compute the fit region with longitude unwrapping. If fewer than 2 valid points remain, use the F2 fallback. Add mock fixtures (for example PHNL→NZAA or PANC→UHMA, plus a corrupt-point track).

### F4. Empty, loading and error states are not designed
- Label: code review finding · **Severity: High** (Sprint 1 requires an `EmptyStateView` component and AC states)
- File/section: specs/screens.md "Not mocked yet: … empty states"; DESIGN_SYSTEM §6 (no EmptyStateView or error component)
- Issue: these aren't designed: a new user with no flights (Home, Flights, Profile stats at 0), a snapshot that's loading or failed, a GPX/KML import that fails or is malformed, a recap export failure, Photos permission denied, or an airport not found in search.
- Fix: add an EmptyStateView spec (symbol, title, body, one action) plus copy for each of the cases above. Snapshot loading = a `surface2` placeholder with a shimmer that's disabled under Reduce Motion. Errors are inline text with an icon, never color alone.

### F5. Glass controls are 40 pt, below the 44 pt minimum target
- Label: code review finding · **Severity: Medium**
- File/section: DESIGN_SYSTEM.md §6 "Glass controls" (40 pt); flight-detail.md "Glass controls" (back 40 pt); §5 says "Min hit target 44×44 pt"
- Fix: keep the 40 pt visual, but use `.contentShape` or a frame of at least 44×44 for the hit area. Also check the start/end dot annotations, the swap button and the trim stepper. Add an AC for Accessibility Inspector hit-target checks.

### F6. Some disclaimer and text contrast isn't verified over glass, maps or dark mode
- Label: code review finding · **Severity: Medium**
- File/section: flight-detail.md "Disclaimer" (caption2 `label2` on glass); DESIGN_SYSTEM §3 `glass.regular` ("Text on it ≥ 4.5:1" with no measured value); map ICAO labels "SF Mono Bold 12 + halo"; recaps rule 4 lists light values only
- Issue: glass contrast depends on what's behind it (route, sky wash, dark map). The dark-mode recap is unspecified, and AC S1 says the export uses a fixed style, so the spec should say which one.
- Fix: state that recaps always export in the Light style (or name the fixed style). Require measured contrast for label/label2 on glass over the worst-case backgrounds in both modes, and for map labels with a halo. Fall back to `glassStrong` when Increase Contrast is on.

### F7. Dynamic Type behavior isn't specified for the fixed-layout surfaces
- Label: code review finding · **Severity: Medium**
- File/section: flight-detail.md (6 StatTiles in a medium-detent sheet, chart scrub capsule); log-flight.md (ICAO SF Mono 20, Out/Off/On/In row); navigation.md (Home summary card); DESIGN_SYSTEM §4 (states reflow 3→2→1 only for stat grids)
- Issue: the AC target is AX3. The specs don't say what happens to the sheet detent, the 4-time row or the route header at AX sizes. Recaps should not scale with Dynamic Type (fixed render), and that isn't stated either.
- Fix: add AX3 layout notes per screen. The Out/Off/On/In row stacks to 2×2 and then a list. The sheet opens at the large detent at AX sizes. Recap text is fixed size and excluded from Dynamic Type.

### F8. VoiceOver labels are only specified for the map
- Label: code review finding · **Severity: Medium**
- File/section: flight-detail.md "VoiceOver" (map only); recaps.md; log-flight.md; DESIGN_SYSTEM §6 FlightCard
- Issue: there are no labels for icon-only glass buttons (back, share, more, close, swap), the visibility pill (it needs "Visibility: Private"), "tap to stamp now" time fields, the trim stepper, recap template chips, the toggles, or the recap preview image. FlightCard isn't specified as a single combined element (A2 / AC S1).
- Fix: add a VoiceOver table per screen with label, value and hint, plus `.accessibilityElement(children: .combine)` for FlightCard. Disclaimer text must be readable by VoiceOver (it's not decorative).

### F9. Accessibility identifiers are incomplete
- Label: code review finding · **Severity: Medium**
- File/section: log-flight.md "IDs" (`log.save`, `log.cancel`, `log.import`, `visibilityPicker`); flight-detail.md and recaps.md (none)
- Issue: MVP-PLAN A7 and the smoke test need ids for Share, the recap toggles, the disclaimer and the map. `visibilityPicker` doesn't follow the `area.element` convention.
- Fix: proposed ids are `detail.map`, `detail.share`, `detail.disclaimer`, `detail.visibility`, `recap.preview`, `recap.toggle.hideHome`, `recap.toggle.trim`, `recap.toggle.tail`, `recap.save`, `recap.share`, `recap.disclaimer`, `log.visibility` (rename), `log.visibility.private|followers|public`, `log.field.dep|arr|date|aircraft`, `flights.list`, `empty.state`.

### F10. No SE or Pro Max layouts; all mockups are 393×852
- Label: code review finding · **Severity: Medium**
- File/section: specs/screens.md (393×852 only); flight-detail.md (map "top ~470 pt", 393×470); maps.md (feed card 361×212)
- Issue: on iPhone SE (375×667, home button), a 470 pt map plus a medium-detent sheet leaves almost nothing visible, and the 5-tab glass capsule geometry (62 pt, 24 pt from the bottom) differs. On Pro Max (440×956), the fixed 361 pt snapshot widths will look letterboxed.
- Fix: express the map height as a fraction of the container (for example 55%), size snapshots from the actual width × the display scale, and add SE and Pro Max frames at least for Flight Detail, Log a Flight with the keyboard up (AC S1) and the Share preview.

### F11. "Hide home airport" appears per flight in the Log form, but the setting/decision is global
- Label: code review finding · **Severity: Low** (low priority per the founder)
- File/section: log-flight.md "Privacy when shared"; privacy-sharing.md "Profile setting: Home airport"; recaps.md Share toggles
- Issue: there are three places (Profile setting, per-flight Log toggle, per-share toggle) and no precedence rule. The decision is that sharing the home airport is optional and off by default. The current defaults are consistent (hidden = ON), but if a user turns it off for one share, does that persist?
- Fix: Profile holds a global "Share my home airport" (default OFF). The Log and Share toggles start from it and override only that flight or share. Document the rule. Sprint 1 can omit the Log-form toggle entirely to keep scope small.

### F12. Disclaimer is missing from Profile → About, and the Log footer wording differs
- Label: code review finding · **Severity: Low**
- File/section: AC "[S1] Privacy requirements" (needs Detail, Recap preview and Profile→About); DESIGN_SYSTEM §8.1 (Detail, Log, recaps); log-flight.md uses "Flyby is a journal · Not for navigation"
- Fix: add an About row to the Profile spec. Keep the exact substring "Not for navigation" everywhere (the smoke-test grep relies on it).

### F13. Features that could read as operational reliability
- Label: code review finding · **Severity: Low**
- File/section: flight-detail.md (Avg GS / Max GS / Max alt, the scrub capsule "11,500 ft · 178 kt", terrain silhouette); log-flight.md (one-tap Out/Off/On/In inspired by an EFB, "Block"); "Approximate route" great-circle line
- Issue: these are fine for a journal, but the terrain silhouette and exact altitude/speed readouts can imply that the data is accurate. "Approximate route" might be read as the route that was flown.
- Fix: label the values as "Recorded" (from GPX) or "Entered". Caption the terrain profile "Illustrative terrain". Use the label "Approximate route (not flown track)". Keep the per-flight logbook times clearly marked as a personal journal and not a certified logbook (also add this to About).

### F14. Photos permission wording conflicts
- Label: code review finding · **Severity: Low**
- File/section: log-flight.md "Photos" ("PHPicker; Photos add-only permission only on Save") vs AC S1 recap ("add-only on recap Save")
- Issue: PHPicker needs no permission, and saving a flight shouldn't request add-only access. Only saving a recap to Photos should.
- Fix: in log-flight.md, say "PHPicker, no permission prompt". Add-only access is requested only on recap Save.

### F15. The proposal is out of date
- Label: code review finding · **Severity: Low**
- File/section: design/proposal.html (title "Design Direction Proposal (v0.1)"; specs are v0.2.1)
- Fix: bump the title and version so reviewers and the founder approve the same revision as the specs.

## Suggested QA plan updates (pending PM agreement)
- Add AC: builds and runs on an iOS 17.x simulator runtime; glass falls back gracefully (F1).
- Add map fixtures and tests: empty, 1-point, invalid-coordinate and antimeridian tracks (F2, F3).
- Expand the A7 id list with the F9 ids.
