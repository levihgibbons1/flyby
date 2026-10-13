# Flyby MVP Plan (Draft v0.2, Oct 13 2026)

Flyby is a premium social flight journal for pilots. **It is not a navigation app.**
Principles: excellent design, smooth performance, simplicity, private by default.

> Status: **Sprint 1 is in progress.** Sprint 1 builds a native SwiftUI prototype on **mock data only** (no Supabase, no network, no accounts). The Sprint 1 Test Plan comes first. The full MVP plan follows it.
> Companion file for GitHub issues: `sprint1-acceptance-criteria.md`

---

## 🧪 Sprint 1 Test Plan (read this first)

### Sprint 1 goal
A native SwiftUI prototype that builds and runs in Xcode with mock data. Covers the 5-tab shell, reusable design components, flight detail with MapKit, manual flight logging, and a shareable flight recap.

### Assumptions (change these here if needed)
- Xcode 26.x, Swift 6 language mode (Swift 5 mode is fine if concurrency warnings get in the way)
- Minimum deployment target: **iOS 17.0** (needed for SwiftUI `Map` with `MapPolyline`/`Marker` and `ImageRenderer`)
- Single app target `Flyby`, plus a `FlybyTests` unit test target and a `FlybyUITests` UI test target
- No third-party dependencies in Sprint 1
- Mock data lives in `Flyby/Mock/` (for example `MockFlights.swift` and `MockAirports.swift`) behind a `FlightStore` protocol, so Supabase can replace it later without UI changes
- Test OS runtimes: **iOS 17.x** (minimum; exercises the Material/classic-TabView/standard-push fallbacks) and **iOS 26.x** (Liquid Glass). Install the iOS 17 runtime via Xcode → Settings → Components if missing.
- Test devices: smallest = **iPhone SE (3rd gen)** simulator (375×667 pt; use iPhone 13 mini or 16e if SE isn't available in your Xcode), largest = **iPhone 17 Pro Max** simulator (440×956 pt, or the current Pro Max)

### Definition of Done (whole sprint)
- [ ] Every deliverable below meets all of its acceptance criteria (AC)
- [ ] The smoke test checklist (bottom of this section) passes on the smallest and largest simulators, on both the iOS 17 and iOS 26 runtimes
- [ ] Builds with zero errors and zero new warnings (or warnings are listed in the PR)
- [ ] No keys, secrets, or tokens in the repo
- [ ] Work is merged through PRs. No direct pushes to `main`, no deploys, no TestFlight uploads.

---

### D1. App builds and runs in Xcode
- [ ] AC1.1 A fresh clone builds with `⌘B` and no manual steps beyond opening `Flyby.xcodeproj`. No signing team is needed for the simulator.
- [ ] AC1.2 `⌘R` launches on the iPhone SE (3rd gen) and iPhone 17 Pro Max simulators with no crash, and the app reaches the Home tab within 2 s on a warm simulator.
- [ ] AC1.3 `xcodebuild build` and `xcodebuild test` succeed from the command line (see smoke test).
- [ ] AC1.4 The app makes no network calls and has no Supabase SDK, URLs, or keys. All data comes from in-memory mock data.
- [ ] AC1.5 A `README.md` covers how to open, build, run, and test, plus required Xcode/iOS versions.
- [ ] AC1.6 Light and dark appearances both supported (no forced `preferredColorScheme`).

### D2. Tab bar: Home, Explore, Record, Flights, Profile
- [ ] AC2.1 `TabView` with exactly 5 tabs in this order: **Home, Explore, Record, Flights, Profile**. Each tab has an SF Symbol and a text label.
- [ ] AC2.2 Each tab shows a real placeholder screen with mock content:
  - Home: feed of the user's own mock recaps (no social features yet)
  - Explore: mock airports list or map
  - Record: entry point to manual flight logging (D5). It does **not** record GPS in Sprint 1.
  - Flights: list of mock flights, newest first, tap opens flight detail (D4)
  - Profile: mock pilot stats (total hours, flights, airports, aircraft)
- [ ] AC2.3 Switching tabs keeps each tab's navigation state. Each tab has its own `NavigationStack`.
- [ ] AC2.4 Each tab has a stable accessibility identifier (for example `tab.home`, `tab.explore`, `tab.record`, `tab.flights`, `tab.profile`) for UI tests.
- [ ] AC2.5 Tab labels are not truncated on iPhone SE at default and AX text sizes. The system tab bar handles this; don't override it.

### D3. Reusable design components
- [ ] AC3.1 A `DesignSystem/` folder holds, at minimum:
  - Color tokens (semantic, for example `Color.flybyBackground`, `.flybyAccent`, `.flybySecondaryText`), all defined in the asset catalog with light and dark variants
  - Type styles built on Dynamic Type text styles (`.largeTitle`, `.headline`, `.body`, and so on), with no hard-coded point sizes
  - Spacing and corner radius constants
  - Components: `StatTile` (value + label), `FlightCard` (route, date, aircraft, duration, mini-map or placeholder), `PrimaryButton`, `SectionHeader`, `VisibilityBadge` (Private / Followers / Public), `EmptyStateView`
- [ ] AC3.2 Every component has a `#Preview` in light mode, dark mode, and at least one large accessibility text size.
- [ ] AC3.3 Screens use components and tokens. No one-off hex colors or magic numbers in feature views (spot-check in PR review).
- [ ] AC3.4 Text and background colors meet WCAG AA contrast (4.5:1 body, 3:1 large text) in both modes.

### D4. Flight detail screen with MapKit
- [ ] AC4.1 Tapping any flight in Flights or Home opens Flight Detail with route (DEP → ARR), date, aircraft type, tail number, block/flight time, distance, notes, and visibility badge.
- [ ] AC4.2 A SwiftUI `Map` shows the mock track as a `MapPolyline`, with departure and arrival markers when they're allowed (see P3). The camera fits the whole route with padding.
- [ ] AC4.3 Flights with no track show a great-circle or straight line between airports and are labeled "Approximate route".
- [ ] AC4.4 The map is decorative or for review only. No turn-by-turn, no live position, no "navigate" actions. The **not-for-navigation disclaimer** (P5) is visible on this screen.
- [ ] AC4.5 Scrolling stays smooth with no visible hitching on a 500+ point mock track, and the map doesn't re-render on every scroll frame.
- [ ] AC4.6 Location permission is **not** requested anywhere in Sprint 1 (no `NSLocationWhenInUseUsageDescription` prompt is triggered).

### D5. Manual flight logging (mock data)
- [ ] AC5.1 The Record tab opens a "Log a Flight" form with date, aircraft type, tail number, departure airport, arrival airport, departure/arrival times (or duration), route (optional text), notes, and visibility.
- [ ] AC5.2 **Visibility defaults to Private** (P2). The user has to change it on purpose.
- [ ] AC5.3 Validation: departure and arrival are required. Airports must match the mock airport list (ICAO/IATA search). Arrival time must be after departure time. Errors are shown inline in text, not by color alone.
- [ ] AC5.4 Saving adds the flight to the in-memory `FlightStore`. It shows at the top of Flights, opens correctly in Flight Detail, and Profile stats update.
- [ ] AC5.5 Cancel discards the entry. If the form has edits, ask for confirmation.
- [ ] AC5.6 The form works with the keyboard up on iPhone SE: fields scroll into view and the Save button can be reached.
- [ ] AC5.7 Unit tests cover the validation rules and the "new flight defaults to Private" rule.

### D6. Shareable flight recap prototype
- [ ] AC6.1 Flight Detail has a "Share Recap" button that opens a recap preview: map snapshot or polyline, route, date, aircraft, key stats, and Flyby branding.
- [ ] AC6.2 The recap image (for example 1080×1350 or 1080×1920) is rendered with `ImageRenderer` (or `MKMapSnapshotter` + overlay) **only after the user taps** Share or Save (P1).
- [ ] AC6.3 Sharing uses the system `ShareLink` or share sheet. Flyby never posts anywhere on its own.
- [ ] AC6.4 Privacy controls on the preview are **on by default**: "Hide home airport" and "Trim track start/end" (P3). "Hide home airport" starts from the global Profile → Privacy setting, which is **On by default** (sharing the home airport is opt-in). Toggling them updates the preview right away; a per-share change is not persisted and doesn't change the global setting.
- [ ] AC6.5 The recap includes a small "Not for navigation" line, or the disclaimer appears on the preview screen (P5).
- [ ] AC6.6 The recap looks right in light and dark mode. The exported image uses a fixed, legible style no matter what the device appearance is.
- [ ] AC6.7 Saving to Photos (if included) uses add-only permission (`NSPhotoLibraryAddUsageDescription`) and asks only when the user taps Save.

---

### 🔒 Sprint 1 privacy acceptance criteria
- [ ] **P1. User-initiated export only.** No recap image is created, cached to disk, or shared unless the user taps Share or Save. Nothing is pre-rendered in the background, written to temp files in advance, or uploaded. *Test:* open Flight Detail and confirm no image files appear in the app container (check the simulator's app data folder) until you tap Share.
- [ ] **P2. Default visibility is Private.** `Flight.visibility` defaults to `.private` in the model initializer and in the Log a Flight form. Mock seed data includes all three visibility levels so the badges can be tested. *Test:* a unit test asserts `Flight(...).visibility == .private`, and a UI test asserts the form opens with Private selected.
- [ ] **P3. Hide or trim home airport and track ends, where feasible.** Profile has a mock "Home airport" setting. On recaps (and in Flight Detail when a "privacy preview" is on), if departure or arrival matches the home airport, its name and marker are hidden, and the polyline drops the first and last ~1 nm (or N points, whichever is easier) of the track. If trimming isn't feasible for a flight, for example a very short track, show a note and hide the endpoints. *Test:* unit tests for `TrackPrivacy.trim(_:distance:)` and `hideHomeAirport`, plus a manual check on a mock flight from the home airport.
- [ ] **P4. No keys or secrets in the repo.** No API keys, Supabase URLs or anon keys, tokens, `.p8`/`.p12`/`.mobileprovision` files, or `.env` files are committed. `.gitignore` covers `*.xcconfig.local`, `.env*`, `*.p8`, `*.p12`, and `xcuserdata/`. *Test:* the secret scan in the smoke test returns no findings.
- [ ] **P5. Not-for-navigation disclaimer.** "Flyby is a flight journal. Not for navigation." (or close to it) appears in at least: Flight Detail (near the map), Profile → About, and the recap preview. It's real text, so VoiceOver reads it.
- [ ] **P6. No permissions requested in Sprint 1** except Photos add-only, and only when the user taps Save. No location, contacts, or tracking prompts, and no analytics SDKs.

### ♿ Accessibility basics
- [ ] A1. **Dynamic Type:** every screen works up to **AX3** (and doesn't crash at AX5). Text wraps instead of truncating key info, and stat rows stack vertically at accessibility sizes.
- [ ] A2. **VoiceOver:** every interactive element has a meaningful label. Icon-only buttons get `accessibilityLabel`. `FlightCard` reads as one element, for example "KPAO to KMRY, Oct 12, Cessna 172, 1 hour 5 minutes, Private". The map has a summary label, not individual points.
- [ ] A3. **Tap targets** are at least 44×44 pt.
- [ ] A4. **Color is never the only signal.** Visibility badges and validation errors include text or an icon.
- [ ] A5. **Contrast** meets AA in light and dark (see AC3.4). Run the Xcode Accessibility Inspector audit on Home, Flights, Flight Detail, Log a Flight, and Recap Preview with no unresolved high-severity issues.
- [ ] A6. **Reduce Motion:** custom animations are skipped or toned down when `accessibilityReduceMotion` is on.
- [ ] A7. Accessibility identifiers are set on key elements for UI tests (tabs, Save, Share, visibility picker).

### 📱 Device layout: smallest and largest iPhones
Run on **iPhone SE (3rd gen)** (375×667 pt, home button, no Dynamic Island) and **iPhone 17 Pro Max** (440×956 pt):
- [ ] L1. Nothing clips or overlaps, and no text truncates in a way that loses meaning, on any of the 5 tabs, Flight Detail, Log a Flight, or Recap Preview.
- [ ] L2. Safe areas are respected (Dynamic Island, home indicator, SE status bar). Maps can extend under bars on purpose, but controls stay inside safe areas.
- [ ] L3. The Log a Flight form is fully usable with the keyboard up on SE (AC5.6).
- [ ] L4. The recap preview scales to fit both screens. The exported image size stays the same on every device.
- [ ] L5. Portrait is required. Landscape can be locked off for Sprint 1, and if it's left on, nothing breaks.
- [ ] L6. Spot-check both devices at the largest default text size and at AX3.

### 🌗 Light and dark mode
- [ ] M1. Every screen and component looks right in Light and Dark. Check through Previews and by toggling the simulator (`⌘⇧A` or Settings → Developer → Dark Appearance).
- [ ] M2. Hard-coded `Color.white`/`.black` appear only where intended (for example the fixed recap export style).
- [ ] M3. The map style suits each mode (MapKit handles this by default, so don't override it).
- [ ] M4. The app icon placeholder and launch screen look fine in both modes.

---

### ✅ Smoke test checklist (for Claude Code / Codex)
Run from the repo root. Change the scheme or simulator names if yours differ (`xcrun simctl list devices available`).

```bash
# 0. Toolchain + runtimes (need an iOS 17.x AND an iOS 26.x simulator runtime)
xcodebuild -version
xcrun simctl list runtimes | grep -E "iOS (17|26)\." || echo "FAIL: install iOS 17 and iOS 26 simulator runtimes"
xcrun simctl list devices available | grep -E "iPhone SE|Pro Max"
# Set these to match your Xcode (OS= must name an installed runtime):
IOS17=17.5   # any installed 17.x
IOS26=26.0   # any installed 26.x
SE="iPhone SE (3rd generation)"
BIG="iPhone 17 Pro Max"          # iPhone 17 Pro Max needs iOS 26; on iOS 17 use iPhone 15 Pro Max
BIG17="iPhone 15 Pro Max"

# 1. Clean build on the minimum OS (smallest device, iOS 17)
xcodebuild -project Flyby.xcodeproj -scheme Flyby \
  -destination "platform=iOS Simulator,name=$SE,OS=$IOS17" \
  clean build CODE_SIGNING_ALLOWED=NO | xcpretty || exit 1

# 2. Unit + UI tests on iOS 17 (fallback paths): smallest + largest
for D in "$SE" "$BIG17"; do
  xcodebuild -project Flyby.xcodeproj -scheme Flyby \
    -destination "platform=iOS Simulator,name=$D,OS=$IOS17" \
    test CODE_SIGNING_ALLOWED=NO | xcpretty || exit 1
done

# 3. Unit + UI tests on iOS 26 (Liquid Glass paths): smallest + largest
for D in "$SE" "$BIG"; do
  xcodebuild -project Flyby.xcodeproj -scheme Flyby \
    -destination "platform=iOS Simulator,name=$D,OS=$IOS26" \
    test CODE_SIGNING_ALLOWED=NO | xcpretty || exit 1
done

# 3b. iOS 18/26-only APIs must stay inside DesignSystem/ (expect no output)
git grep -nE "glassEffect|GlassEffectContainer|glassEffectID|buttonStyle\(\.glass|tabBarMinimizeBehavior|navigationTransition|matchedTransitionSource" -- '*.swift' ':!Flyby/DesignSystem/*' && echo "FAIL: gated API outside DesignSystem" || echo "OK: gated APIs wrapped"

# 4. Secret scan (expect no output / zero findings)
#    Preferred: gitleaks detect --source . --no-banner
git grep -nIE "(sk_live|sk_test|eyJhbGciOi|supabase\.co|SUPABASE_(URL|ANON|SERVICE)|api[_-]?key\s*[:=]|BEGIN (RSA|EC|PRIVATE) KEY)" -- . ':!*.md' || echo "OK: no secrets found"
git ls-files | grep -E "\.(p8|p12|mobileprovision|env)$|\.env\." && echo "FAIL: secret-type file committed" || echo "OK: no secret files"

# 5. No networking / backend SDKs in Sprint 1 (expect no matches)
git grep -nE "import Supabase|URLSession|supabase" -- '*.swift' || echo "OK: no network code"

# 6. Privacy defaults present
git grep -nE "visibility.*=.*\.private|case private" -- '*.swift'
git grep -niE "not for navigation" -- '*.swift'
git grep -nE "hideHomeAirport.*=.*true|hideHomeAirport: Bool = true" -- '*.swift' || echo "CHECK: global Hide home airport should default to true"
```

Automated tests that should exist (in `FlybyTests` / `FlybyUITests`):
- [ ] `FlightTests.testDefaultVisibilityIsPrivate`
- [ ] `FlightValidationTests` (required airports, arrival after departure, unknown airport rejected)
- [ ] `TrackPrivacyTests` (trim removes start/end, hide home airport, short-track fallback)
- [ ] `PrivacySettingsTests.testHideHomeAirportDefaultsOn` and `testShareOverrideDoesNotPersist`
- [ ] `TrackGeometryTests` (0/1/2/512-point, corrupt-point and antimeridian fixtures from `design/specs/maps.md`)
- [ ] `FlightStoreTests.testSaveAddsFlightAndUpdatesStats`
- [ ] `RecapTests.testNoImageRenderedBeforeUserAction`: the renderer is invoked lazily, checked with a spy or counter
- [ ] UI: `testTabBarHasFiveTabsInOrder`
- [ ] UI: `testLogFlightDefaultsToPrivateAndAppearsInFlights`
- [ ] UI: `testFlightDetailShowsMapAndDisclaimer`
- [ ] UI: `testShareRecapShowsPreviewWithPrivacyTogglesOn`

Manual smoke pass (about 10 minutes, on each of the two devices, on **iOS 17 and iOS 26**, in Light and then Dark):
1. [ ] Launch the app. Home loads with mock recaps.
2. [ ] Tap through all 5 tabs and confirm the order and labels.
3. [ ] Flights → open a flight. The map draws the route and the disclaimer is visible.
4. [ ] Record → log a new flight. Visibility shows **Private**. Save, and it shows at the top of Flights, opens in detail, and Profile stats update.
5. [ ] Try invalid input (missing arrival, arrival before departure) and confirm the inline errors.
6. [ ] Profile → Settings → Privacy shows "Hide home airport" **On** by default. Flight Detail → Share Recap on a flight from the mock home airport: the preview opens with Hide home airport and Trim ends **on** and the home field shown as a region label. Toggle them and the preview updates. Tap Share and the system share sheet appears. Cancel.
7. [ ] Confirm no location permission prompt appeared at any point.
8. [ ] Set text size to AX3 and repeat steps 2–4 briefly.
9. [ ] Turn VoiceOver on and swipe through Flights and one Flight Detail. Labels make sense.
10. [ ] On iOS 17 only: glass surfaces fall back to Material/bordered buttons, the tab bar is the classic bar with all 5 tabs, Record opens the Log sheet, and nothing is missing or crashes.

### Out of scope for Sprint 1
Supabase, auth or Sign in with Apple, networking, real GPS recording, GPX/KML import, social features (follows, feed, kudos, comments), achievements, widgets, TestFlight, App Store work.

---
---

## Full MVP Plan

### Product summary
- **What:** a premium social flight journal. Pilots log flights, see beautiful recaps, and share them on their own terms.
- **Who:** private and recreational pilots and student pilots first, then CFIs and flying clubs.
- **Not:** a navigation, EFB, or flight-planning app. No guidance, no real-time traffic, and no regulatory logbook claims at MVP.
- **Principles:** excellent design, smooth performance, simplicity, private by default.

### MVP scope (what "MVP" means)
A TestFlight-ready iOS app where a pilot can:
1. Sign in with Apple
2. Log flights manually and/or import a GPX/KML track
3. See each flight as a rich detail page and map recap
4. Keep flights private by default and choose per-flight visibility (Private / Followers / Public)
5. Follow other pilots and see a simple feed of shared recaps, with kudos and comments
6. Export a shareable recap image with location privacy controls
7. See a pilot profile with hours, aircraft, and airports visited

### Phases and sprints (2-week sprints)
| Phase | Weeks | Sprints | Outcome |
|---|---|---|---|
| 0 Foundations | 1–3 | **S1 (now)**, S2 | Mock-data SwiftUI prototype (S1). Supabase schema, RLS, auth, and CI (S2). |
| 1 MVP Journal | 4–9 | S3–S5 | Real persistence, manual logging, GPX/KML import, flight detail, profile, airport DB |
| 2 Social | 10–15 | S6–S8 | Follows, feed, kudos/comments, recap export, blocking/reporting, location privacy |
| 3 Delight | 16–22 | S9–S11 | Achievements, airport discovery, Year in Flight, widgets |
| 4 Premium & Launch | 23–28 | S12–S14 | Premium (pending approval), perf/a11y pass, App Store assets, TestFlight, submission (approval required) |

### Phase 0: Foundations (weeks 1–3)
- **Sprint 1 (current):** SwiftUI prototype on mock data. See the Sprint 1 Test Plan above.
- **Sprint 2:**
  - Supabase schema: `users`, `profiles`, `flights`, `tracks`, `follows`, `airports`, `aircraft`, `achievements`
  - Row-level security: flights private by default; per-flight `visibility` enum (`private`, `followers`, `public`); owners can always read and write their own
  - Sign in with Apple to Supabase Auth
  - Swap mock `FlightStore` for a `SupabaseFlightStore` behind the same protocol. Keys go through an untracked `.xcconfig`, never committed.
  - GitHub Actions CI: build + unit tests on PRs, plus a secret scan (gitleaks)
  - Data/privacy policy draft (not published without Levi's approval)

### Phase 1: MVP Journal (weeks 4–9)
- Manual flight logging against real persistence: aircraft, tail number, departure/arrival, times, route, notes, photos
- GPX/KML import for tracks, and MapKit route rendering with simplification for long tracks
- Flight detail recap card (map, stats, photos)
- Pilot profile: total hours, aircraft flown, airports visited
- Airport database seeded from public data, with simple airport pages (source and licensing are an open decision)
- Offline-friendly: log works without connectivity and syncs later

### Phase 2: Social (weeks 10–15)
- Follow / followers, plus request-to-follow for private accounts
- Feed of shared recaps, likes ("kudos"), comments
- Shareable recap images (export only on user action)
- Blocking, reporting, moderation basics
- Location privacy: hide home airport, trim track start/end (built for real on top of the Sprint 1 prototype logic)

### Phase 3: Delight and Retention (weeks 16–22)
- Achievements: first solo, new airports, states/countries, night, cross-country
- Airport discovery: visited map, "airports near you", pilot notes
- Yearly stats and recap ("Year in Flight")
- Widgets, plus Live Activities for an in-progress log (journal only, no nav guidance)

### Phase 4: Premium and Launch (weeks 23–28)
- Flyby Premium (pricing needs Levi's approval)
- Performance pass, accessibility audit, App Store assets
- App Store privacy labels (Privacy & Compliance bot to draft)
- TestFlight beta, then App Store submission (approval required)

### Cross-cutting quality bars (all sprints)
- **Privacy:** private by default, user-initiated sharing only, minimal permissions, no secrets in the repo, no third-party trackers
- **Safety:** a not-for-navigation disclaimer wherever maps or tracks appear
- **Accessibility:** Dynamic Type, VoiceOver, contrast AA, Reduce Motion
- **Performance:** 60/120 fps scrolling on lists and maps, cold launch under 1.5 s on a recent iPhone, track rendering simplified past about 2k points
- **Design:** one design system. Components get previews in light, dark, and large text.
- **Process:** PRs only, CI green before merge, no deploys or store submissions without Levi's approval

### Team / specialist bots
- Design Lead: design system, SwiftUI specs, flow reviews
- iOS Engineer: SwiftUI/MapKit features via Claude Code / Codex, PRs only (no deploys)
- Backend Engineer: Supabase schema, RLS policies, edge functions, migrations (starts Sprint 2)
- QA & Performance: owns this test plan, TestFlight feedback triage, perf profiling
- Privacy & Compliance: privacy defaults, App Store privacy labels, data policy
- Aviation Data: airport DB, aircraft types, import formats (GPX/KML/ForeFlight)
- Growth & Community (later): App Store copy, beta recruiting (drafts only)

### Risks
- MapKit performance with long tracks. Mitigation: Douglas-Peucker simplification and snapshot caching after the user acts.
- Airport data licensing. Mitigation: decide the source early (Aviation Data bot).
- Location privacy leaks through recaps. Mitigation: privacy toggles on by default, plus tests (P3).
- Scope creep into navigation features. Mitigation: explicit non-goal and disclaimer.

### Open decisions for Levi
1. Track source at launch: manual + GPX import only, or in-app GPS recording?
2. Monetization model and timing
3. Seed airport data source and licensing
4. Minimum iOS version (plan assumes iOS 17+)
5. Default for "Hide home airport" outside recaps (feed/profile). **Decided:** one global setting, On by default; sharing the home airport is opt-in (low priority for Sprint 1).
