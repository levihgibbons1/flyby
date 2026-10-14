# Design review: PR #13 (scaffold) + PR #14 (Main TabView)

Reviewer: Design · Date: Oct 13, 2026 · Against: Skyglass v0.3.1 (`/workspace/flyby/design/`)
Inputs:
- `review/se-ios17.png`, `review/pm-ios17.png`, `review/se-ios26.png`, `review/pm-ios26.png`. Every file was reviewed: 6 screens × Light / Dark / AX3 on each.
- PR diffs #13 (`feature/1-scaffold`, head `ea7a58a`) and #14 (`feature/2-tabview`, head `1e3ffe4`). Both were read only; no comments or approvals were posted.

## Verdict: **PASS with fixes**

No Blockers and no Highs. The tab architecture matches `navigation.md`:
- 5 tabs, in the right order, with the right symbols and `tab.*` ids
- Record works as an action
- each tab has its own NavigationStack
- iOS 26 gating lives in DesignSystem

Accessibility basics hold on all 4 devices: 44 pt targets, Dynamic Type through AX3, and the "Not for navigation" disclaimer. The Med items below should be fixed in #14 (M1, M3) or explicitly carried into #3 or #4 before Sprint 1 sign-off (M2, M4, M5).

## What the PRs implement
- **#13:**
  - Xcode project with an iOS 17.0 deployment target, three targets and a shared scheme
  - DesignSystem, Features, Models and MockData folders
  - `AccentColor` = `#0A63DB` / `#4DA3FF`
  - gitignore for secrets, and no networking or Supabase code
- **#14:**
  - `RootView` TabView using `.tabItem`
  - `AppTab` enum
  - Record intercept through the selection binding, which shows the `LogFlightSheet` placeholder
  - `TabBarAccessibilityIdentifiers`, a UIKit shim that sets the `tab.*` ids
  - `DesignSystem/LiquidGlass.swift`: `flybyTabBarMinimizeOnScroll`, `flybyGlass(in:)`, and the glass and prominent button styles, with `.regularMaterial` and `.borderedProminent` fallbacks and a Reduce Transparency solid
  - `SectionHeaderText` in label2
  - `Label2` and `OnPrimary` colorsets
  - Placeholder Home, Explore, Flights (push to a placeholder detail) and Profile screens, built on inset-grouped `List`
  - UI tests: tab order, ids, Record keeps the previous tab, state survives tab switches, accessibility audit, screenshot capture

## Checklist
| Area | Result | Notes |
|---|---|---|
| Tokens / colors | ⚠️ Partial | AccentColor, Label2 and OnPrimary hex values match §3 exactly. bg and surface are still system colors (M2) |
| Type | ✅ / Low | SF Pro for words; SF Mono for ICAO codes (`.body.monospaced().semibold`). Stats aren't present yet |
| Spacing / radius | ⚠️ Deferred | System List insets and radii. Card 24 and tile 18 aren't applied yet (M2) |
| Glass / fallback | ✅ / Med | iOS 26: floating glass tab bar, lens selection, glass sheet, glass X close button, `.glassProminent` CTA. iOS 17: classic bar, `.borderedProminent` capsule. No thin or ultraThin material anywhere. Map variant missing (M4) |
| Map style | n/a | No maps in #13/#14; this becomes the #5 gate |
| Tab bar | ✅ | Order, symbols, ids, Record as the only tinted item, intercept, minimize-on-scroll (iOS 26). Low: `Tab(...)` isn't used on iOS 18+ (L1) |
| Disclaimer | ✅ / Med | "Not for navigation" appears in Profile → About and in the Log footer. Copy and ids are off spec (M3) |
| Privacy | ✅ / Med | "Private" on every row, "Only you" on the summary, the sheet states Private by default, no location code. Hide home airport setting missing (M5) |
| 44 pt targets | ✅ | Rows, All flights and the CTA use `minHeight: 44`; system toolbar and tab items |
| Dynamic Type (AX3) | ✅ / Low | Rows stack the visibility label and the Profile header stacks at AX sizes; everything scrolls with nothing clipped. Tab labels use the Large Content Viewer (system). Route wrap: L3 |

## Issues

### M1 · Med · List row separators start at the "Private" label instead of the row's leading edge
- **Screenshot:** all four files, Home and Home (bottom), plus Flights, in Light, Dark and AX3. In `se-ios17` Light, the separators under KPAO/KSQL/KHAF run only from "Private" to the trailing edge, so rows look broken. The same thing shows in `pm-ios26`.
- **Spec:**
  - `DESIGN_SYSTEM.md` §5: FlightRow with route, VisibilityPill, date · aircraft
  - `png/01-home-journal.png`: full-width row dividers inset to the content leading edge
- **Cause:** in an HStack, SwiftUI aligns `listRowSeparatorLeading` to the *last* text-bearing view, which is the `Label("Private")` in `PlaceholderFlightRow`.
- **Fix:** in `PlaceholderFlightRow`, pin the guide to the row's leading edge, and carry this into the real `FlightRow` in #4:
  ```swift
  layout { … }
    .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
  ```

### M2 · Med · App background and surfaces are system grays, not Skyglass tokens (no sky wash; radii not applied)
- **Screenshot:** every panel. Sampled pixels:
  - Light bg `#F2F2F7`; spec `bg #F5F8FC` with the `skyWash #DCEBFF → bg` at top
  - Dark bg `#000000` and cards `#1C1C1E`; spec `bg #0A0F1A`, `surface #141B28`
  - See `se-ios17` and `pm-ios17` Dark rows: the UI reads as stock iOS, not Skyglass
  - List card corners are system: ~10 pt on iOS 17 and ~26 on iOS 26, against the spec's card 24 and tile 18
- **Spec:** `DESIGN_SYSTEM.md` §3 (bg, surface, surface2, skyWash) and §4 (radius); `png/09-home-journal-dark.png`.
- **Fix (in #3, since the PR body defers tokens there; track it explicitly):**
  1. Add the `Color.Flyby.*` colorsets: bg, surface, surface2, label, label3, sep, primary.
  2. On each root List, apply `.scrollContentBackground(.hidden).background(Color.Flyby.bg)` with a top `skyWash` gradient behind the nav bar.
  3. Apply `.listRowBackground(Color.Flyby.surface)`.
  4. Move the reduce-transparency fill from `secondarySystemGroupedBackground` to `surface`. This also covers the L4 item in `LiquidGlass.swift`.
  5. Until #3 lands, don't add any more `Color(.system…)` uses in feature views.

### M3 · Med · Disclaimer copy and ids differ from spec
- **Screenshot:** Profile → About ("Flyby is a flight journal. Not for navigation.") and the Log sheet footer ("Flyby is a journal · Not for navigation"), in all four files.
- **Spec:**
  - `log-flight.md` (Save row): "Personal journal · Not for navigation", id `log.disclaimer`
  - `navigation.md` and `accessibility.md` §ids: About text "**Not for navigation.** Flyby is a personal flight journal. It isn't a certified logbook…", id `about.disclaimer`
- **Status:** the required substring is present, so this isn't a blocker. However, the Profile id is `profile.disclaimer` and the Log footer has no id, so QA's id-based checks will fail.
- **Fix:**
  - Rename the Profile id to `about.disclaimer`.
  - Add `.accessibilityIdentifier("log.disclaimer")` to the Log footer and change its copy to "Personal journal · Not for navigation".
  - Use the full About copy now, or when Settings lands (M5), but keep the id stable.

### M4 · Med · `flybyGlass` has no on-map variant (needs `.thickMaterial` plus mapScrim)
- **Screenshot:** n/a; this is in the code (`DesignSystem/LiquidGlass.swift`). The iOS 17 fallback is always `.regularMaterial`.
- **Spec:**
  - `platform-fallbacks.md` API table: `flybyGlass(cornerRadius:onMap:)`. On maps it's `MapScrim` + `.thickMaterial`; elsewhere `.regularMaterial`.
  - `flybyGlassButton(prominent:onMap:)`
  - `accessibility.md` §2b: measured worst case for thick + scrim, light 15.9 / 6.4 / 4.7
- **Fix:** before #5 (Flight Detail map):
  1. Add `onMap: Bool = false`. When it's true and the OS is below iOS 26, render `Color.Flyby.bg.opacity(0.6 light / 0.7 dark)` under `.thickMaterial`.
  2. Use the same path for glass buttons on maps, with a `label`-colored glyph.
  3. Align the wrapper names with the spec, or update the spec and the CI grep doc to match.
- Not needed for #14's screens.

### M5 · Med · Profile has no Settings → Privacy → "Hide home airport" (On by default)
- **Screenshot:** the Profile column in all four files shows only "New flights are Private by default".
- **Spec:**
  - `privacy-sharing.md` §1 (global toggle, On by default, id `settings.hideHome`; Sprint 1 mock `ProfileStore.hideHomeAirport = true`)
  - `navigation.md` (Settings gear, 44 pt)
  - `png/19-settings-privacy-about.png`
  - Sprint-1 AC manual pass: "Settings → Privacy shows Hide home airport On"
- **Fix:** out of scope for #2, but tie it to an issue (#4 or the Settings issue). Add a 44 pt Settings gear in Profile's toolbar that pushes Privacy (`Toggle("Hide home airport", isOn: $store.hideHomeAirport)`, id `settings.hideHome`) and About. Move the About disclaimer into Settings to match `png/19`.

### L1 · Low · `.tabItem` is used on every OS; spec calls for `Tab(_:systemImage:value:)` on iOS 18+
- **Screenshot:** visually fine. `se-ios26` and `pm-ios26` already get the floating glass bar.
- **Spec:**
  - `navigation.md` Behavior (version gating)
  - `platform-fallbacks.md` (`FlybyTabView`)
- **Fix:** either:
  - add `FlybyTabView` with an `if #available(iOS 18)` `Tab(value:)` path, which may also let you drop the UIKit id shim; or
  - record a spec deviation: `.tabItem` works on iOS 26.
- If you keep `.tabItem`, add `.tint(Color.Flyby.primary)` explicitly on the TabView instead of relying on AccentColor.
- The binding-setter intercept (instead of `onChange`) is **better** than spec, because the bar never flashes Record. Keep it and update `navigation.md`.

### L2 · Low · Visibility is a bare caption Label, not a VisibilityPill
- **Screenshot:** the Home and Flights rows: lock icon, a wide gap, then "Private" at ~12 pt (`se-ios17` Light).
- **Spec:**
  - `DESIGN_SYSTEM.md` §3 ("Visibility is always icon + label", Private = `lock.fill` label2)
  - §5 VisibilityPill
  - `png/01`
- **Fix (in #3/#4):**
  - Build a `VisibilityPill(visibility:)` capsule with a `surface2` fill, 4/8 padding, and `.labelStyle` tight spacing (4 pt).
  - Drive it from `flight.visibility` instead of a hard-coded "Private".
  - Set the accessibility label to "Visibility: Private".

### L3 · Low · Route title wraps mid-route at AX3 on SE
- **Screenshot:** `se-ios26` AX3 Flights shows "KPAO" on one line and "→ KMRY" on the next. `se-ios17` AX3 fits. This is an acceptable reflow but reads poorly.
- **Spec:** `accessibility.md` (AX3 fully laid out); `DESIGN_SYSTEM.md` §4 (routeCode SF Mono).
- **Fix:** render the route as `ViewThatFits { HStack { dep; arrow; arr } ; VStack(alignment: .leading) { dep; HStack { arrow; arr } } }`, or keep each code non-breaking (`"KPAO\u{00A0}→\u{00A0}KMRY"`). Also, the arrow should be decorative for VoiceOver ("KPAO to KMRY").

### L4 · Low · Reduce Transparency solid uses `secondarySystemGroupedBackground`
- **Spec:** `platform-fallbacks.md`: Reduce Transparency → solid `surface`.
- **Fix:** swap to `Color.Flyby.surface` when #3 adds the token; this is covered by M2.

### L5 · Low · Home "Log a Flight" CTA isn't in the Home journal spec, and on SE it sits under the tab bar in the first viewport
- **Screenshot:** `se-ios17` and `se-ios26` Home: the button is cut by the tab bar until you scroll.
- **Spec:** `navigation.md` Home journal mode (summary card, Recent flights, All flights) and `png/01`. The empty state `png/15` is where the CTA belongs.
- **Fix:** keep the CTA only for the empty state (`empty.state`), or accept it as a temporary placeholder and remove it with #4. Record already covers the action.

### L6 · Low · Accessibility-audit allow-list is broad
- **Location:** `AccessibilityAuditUITests.isKnownFalsePositive`. `label == nil` ignores *every* element-less dynamicType or textClipped issue, and every contrast issue behind the tab bar.
- **Spec:** `accessibility.md` (audit gate).
- **Fix:** match on `issue.compactDescription` plus element type (tabBar) rather than nil. Re-check the list after #3 changes colors.

## Positive notes (keep)
- Tab ids are verified via an accessibility-tree dump, with a UI test for order, labels and Record keeping the previous tab.
- No location APIs, and the sheet copy says "Flyby never records your live position."
- `onPrimary` navy on `#4DA3FF` in Dark (7.2:1). This is correct and matches `png/09`.
- Gated APIs exist only in `DesignSystem/LiquidGlass.swift`, so the CI grep from the Sprint 1 AC passes.
- AX layouts: row and Profile header switch to a VStack; section headers are `label2` with `.textCase(nil)`.
