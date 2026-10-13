# Sprint 1 Acceptance Criteria (GitHub issues)

Paste each section below into its own GitHub issue. Title = the `##` heading, body = everything under it.
Suggested labels: `sprint-1`, plus the area label shown on each issue. Full details: `MVP-PLAN.md` → Sprint 1 Test Plan.
Sprint 1 rules: **mock data only** (no Supabase or networking), PRs only, no deploys.

---

## [S1] App builds and runs in Xcode
**Labels:** `sprint-1`, `ios`

- [ ] A fresh clone builds with ⌘B. No manual steps, and no signing team needed for the simulator.
- [ ] Runs on the iPhone SE (3rd gen) and a Pro Max simulator with no crash, on **both an iOS 17.x and an iOS 26.x runtime** (iPhone 17 Pro Max on 26; iPhone 15 Pro Max on 17)
- [ ] iOS 18/26-only APIs (Liquid Glass, `Tab`, zoom transition, tab-bar minimize) are only used inside `DesignSystem/` wrappers with iOS 17 fallbacks
- [ ] `xcodebuild build` and `xcodebuild test` pass from the CLI
- [ ] No network calls, no Supabase SDK or URLs. Mock data only.
- [ ] README covers open/build/run/test and the required Xcode and iOS versions (iOS 17+)
- [ ] Zero build errors, and any new warnings are listed in the PR

---

## [S1] Tab bar: Home, Explore, Record, Flights, Profile
**Labels:** `sprint-1`, `ios`, `design`

- [ ] `TabView` with 5 tabs in this order: Home, Explore, Record, Flights, Profile (SF Symbol + label each)
- [ ] Each tab shows a placeholder screen with mock content (Record opens manual logging and does not record GPS)
- [ ] Each tab has its own `NavigationStack`, and its state survives tab switches
- [ ] Accessibility identifiers: `tab.home`, `tab.explore`, `tab.record`, `tab.flights`, `tab.profile`
- [ ] Labels don't truncate on iPhone SE

---

## [S1] Reusable design components
**Labels:** `sprint-1`, `design`, `ios`

- [ ] `DesignSystem/` with semantic color tokens (light and dark in the asset catalog), Dynamic Type–based type styles, and spacing/radius constants
- [ ] Components: `StatTile`, `FlightCard`, `PrimaryButton`, `SectionHeader`, `VisibilityBadge`, `EmptyStateView`
- [ ] Each component has `#Preview`s for light, dark, and a large accessibility text size
- [ ] No hard-coded hex colors or font sizes in feature views
- [ ] Contrast meets WCAG AA in both modes

---

## [S1] Flight detail screen with MapKit
**Labels:** `sprint-1`, `ios`, `maps`

- [ ] Shows route, date, aircraft, tail number, time, distance, notes, and visibility badge
- [ ] SwiftUI `Map` with a `MapPolyline` track, DEP/ARR markers (subject to privacy rules), and a camera that fits the route
- [ ] Flights with no track show a straight or great-circle line labeled "Approximate route"
- [ ] No navigation features (no live position, no guidance)
- [ ] The **"Not for navigation"** disclaimer is visible near the map
- [ ] Smooth with a 500+ point mock track
- [ ] No location permission requested

---

## [S1] Manual flight logging (mock data)
**Labels:** `sprint-1`, `ios`

- [ ] Log a Flight form: date, aircraft, tail number, DEP, ARR, times or duration, route, notes, visibility
- [ ] **Visibility defaults to Private**
- [ ] Validation: DEP and ARR required and must be in the mock airport list, arrival after departure. Errors shown inline in text.
- [ ] Save adds the flight to the in-memory store. It shows first in Flights, opens in detail, and Profile stats update.
- [ ] Cancel asks for confirmation if there are unsaved edits
- [ ] Usable with the keyboard up on iPhone SE
- [ ] Unit tests cover validation and the default-Private rule

---

## [S1] Shareable flight recap prototype
**Labels:** `sprint-1`, `ios`, `privacy`

- [ ] "Share Recap" on Flight Detail opens a preview (map, route, date, aircraft, stats, branding)
- [ ] The image is rendered **only after the user taps** Share or Save. No background pre-rendering or disk caching.
- [ ] Sharing uses the system `ShareLink` or share sheet. The app never posts on its own.
- [ ] "Hide home airport" and "Trim track start/end" toggles are **on by default** and update the preview live. Hide home airport starts from the global Profile → Privacy setting (**On by default**); a per-share change isn't persisted
- [ ] The recap includes a "Not for navigation" line
- [ ] Export uses a fixed, legible style no matter what the device appearance is
- [ ] Photos permission (add-only) is requested only when the user taps Save

---

## [S1] Privacy requirements
**Labels:** `sprint-1`, `privacy`

- [ ] **User-initiated export only:** no recap image is created, cached, or shared without a user tap (unit test with a renderer spy)
- [ ] **Default visibility is Private:** the `Flight` model and Log form both default to `.private` (unit + UI test)
- [ ] **Hide or trim the home airport and track ends where feasible:** mock home airport in Profile, and a global "Hide home airport" setting that defaults to **On** (sharing it is opt-in). Recaps hide a matching endpoint and trim about 1 nm or N points from the track ends. Very short tracks fall back to hiding the endpoints. Covered by `TrackPrivacyTests`.
- [ ] **No keys or secrets in the repo:** `.gitignore` covers `.env*`, `*.p8`, `*.p12`, `*.xcconfig.local`, and `xcuserdata/`. Secret scan is clean.
- [ ] **Not-for-navigation disclaimer** in Flight Detail, Recap preview, and Profile → About, as real text that VoiceOver reads
- [ ] No permissions besides Photos add-only (on Save). No analytics or tracking SDKs.

---

## [S1] Accessibility, device layout, and appearance
**Labels:** `sprint-1`, `accessibility`, `qa`

- [ ] Dynamic Type works up to AX3 (no crash at AX5), with stat rows stacking at accessibility sizes
- [ ] VoiceOver labels on every control. `FlightCard` reads as one element, and the map has a summary label.
- [ ] Tap targets are at least 44×44 pt, and color is never the only signal
- [ ] Accessibility Inspector audit has no high-severity issues on the key screens
- [ ] Reduce Motion is respected
- [ ] Layout checked on iPhone SE (3rd gen) and iPhone 17 Pro Max: no clipping or overlap, safe areas respected, recap preview scales
- [ ] Every screen checked in Light and Dark mode, and the map uses the system style

---

## [S1] Smoke test (Claude Code / Codex)
**Labels:** `sprint-1`, `qa`

```bash
# Set to installed runtimes (xcrun simctl list runtimes)
IOS17=17.5; IOS26=26.0
xcodebuild -project Flyby.xcodeproj -scheme Flyby -destination "platform=iOS Simulator,name=iPhone SE (3rd generation),OS=$IOS17" clean build CODE_SIGNING_ALLOWED=NO
xcodebuild -project Flyby.xcodeproj -scheme Flyby -destination "platform=iOS Simulator,name=iPhone SE (3rd generation),OS=$IOS17" test CODE_SIGNING_ALLOWED=NO
xcodebuild -project Flyby.xcodeproj -scheme Flyby -destination "platform=iOS Simulator,name=iPhone 15 Pro Max,OS=$IOS17" test CODE_SIGNING_ALLOWED=NO
xcodebuild -project Flyby.xcodeproj -scheme Flyby -destination "platform=iOS Simulator,name=iPhone SE (3rd generation),OS=$IOS26" test CODE_SIGNING_ALLOWED=NO
xcodebuild -project Flyby.xcodeproj -scheme Flyby -destination "platform=iOS Simulator,name=iPhone 17 Pro Max,OS=$IOS26" test CODE_SIGNING_ALLOWED=NO
gitleaks detect --source . --no-banner   # or the git grep scan in MVP-PLAN.md
git grep -nE "import Supabase|URLSession" -- '*.swift' || echo "OK: no network code"
git grep -niE "not for navigation" -- '*.swift'
git grep -nE "glassEffect|GlassEffectContainer|glassEffectID|buttonStyle\(\.glass|tabBarMinimizeBehavior|navigationTransition|matchedTransitionSource" -- '*.swift' ':!Flyby/DesignSystem/*' && echo "FAIL" || echo "OK: gated APIs wrapped"
```

- [ ] Build passes on SE (iOS 17), and tests pass on SE and Pro Max on **both iOS 17 and iOS 26**
- [ ] Secret scan clean, and no network code
- [ ] Manual pass in Light and Dark on both devices, on iOS 17 and iOS 26: tabs → flight detail (map + disclaimer) → log a flight (defaults to Private, shows in Flights, stats update) → invalid input errors → Settings → Privacy shows Hide home airport **On** by default → Share Recap (privacy toggles on, home field shown as region, share sheet) → no location prompt → AX3 spot-check → VoiceOver spot-check
- [ ] Contrast check (design accessibility.md §2b, closes QA N2): on iOS 17 iPhone SE and iPhone 15 Pro Max, in Light and Dark, measure text contrast on glass/fallback controls over the map (mapScrim + .thickMaterial) using the Accessibility Inspector audit or screenshots. The minimum is 4.5:1 for body text and 3:1 for large text and icons. Attach the measured values to the PR.
