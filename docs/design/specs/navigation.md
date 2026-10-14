# Spec: Navigation & tab bar (v0.3.2 Skyglass, provisional)

Tabs (founder kickoff; matches `MVP-PLAN.md` D2), left to right:

| # | Tab | SF Symbol | A11y id | Content |
|---|---|---|---|---|
| 1 | Home | `house.fill` | `tab.home` | Pre-social: journal mode. Post-social: `Following | You` segmented feed |
| 2 | Explore | `globe.americas.fill` | `tab.explore` | Airports visited and wishlisted, airport pages (discovery, not planning) |
| 3 | **Record** (center) | `plus.circle.fill`, tinted Flyby Blue | `tab.record` | Presents the **Log a Flight** sheet (manual entry or GPX/KML import) |
| 4 | Flights | `book.closed.fill` | `tab.flights` | The user's **logbook list**: search, filter chips, totals header, flights grouped by month; rows open Flight Detail |
| 5 | Profile | `person.crop.circle.fill` | `tab.profile` | Totals, logbook stats, aircraft, achievements, settings & privacy |

Behavior
- Standard SwiftUI `TabView`, so don't add a custom background. **Version gating (F1, `platform-fallbacks.md`):**
  - **All versions (iOS 17 → 26):** the classic `.tabItem { Label(…) }.tag(AppTab…)` items, one code path. On iOS 26 this still gives the floating Liquid Glass tab bar, the lens highlight and glass sheets automatically (verified in the PR #14 screenshots). `Tab(_:systemImage:value:)` is **not** used, so there's no `FlybyTabView` version split.
  - Ids `tab.*` are set on the underlying `UITabBarItem`s by the shim `App/TabBarAccessibilityIdentifiers.swift`, because SwiftUI doesn't forward `.accessibilityIdentifier` from `.tabItem` to the tab-bar button.
  - Use `.tint(Color.Flyby.primary)` on all versions.
  - `flybyTabBarMinimizeOnScroll()` applies `.tabBarMinimizeBehavior(.onScrollDown)` on iOS 26 only (the bar shrinks while scrolling down on Home, Explore and Flights). It's a no-op on 17/18.
- **Record is an action, not a destination.** It's a real tab (tag `AppTab.record`, a `Color.clear` placeholder that is never shown). The `TabView(selection:)` binding's **setter intercepts** it: when the new value is `.record`, it sets `showLog = true` and leaves `selection` unchanged; otherwise it assigns the selection. This presents the Log a Flight sheet (a glass sheet on iOS 26, the standard sheet on 17/18). Because the selection never changes to Record, the bar never shows or flashes an empty Record screen, and the previous tab stays highlighted. Don't use `onChange(of: selection)` to revert. This satisfies the 5-tab spec while respecting the HIG guidance that tab bars are for navigation.
- Record is the only tinted tab item. Tab-bar items ignore SwiftUI foreground styles, so the Record symbol is tinted by baking the dynamic `AccentColor` into the image (`UIImage.withTintColor(_:renderingMode: .alwaysOriginal)`); it adapts Light/Dark. Selected tabs get the system glass "lens" highlight plus the primary tint.
- Home journal mode: large title "Home", "2026 so far" summary card (progress ring toward an hours goal, flights, airports, distance; "Only you" pill), "Recent flights" (3 compact rows with visibility pills), and an "All flights" link that switches to the Flights tab.
- Home social mode (later): large title "Home", `Following | You`, feed posts (author · time · aircraft · visibility, title, trimmed map, 3 stats, Tailwinds / comments / share).
- Achievements live in Profile (section + full gallery). They don't get a tab.
- Labels are always shown. Large-content viewer at accessibility sizes. Each tab item's hit area is ≥ 44 pt (system).
- Card → Flight Detail: zoom transition on iOS 18+ (`flybyZoomSource/Destination`), standard push on iOS 17.
- Profile → **Settings** (gear, 44 pt) holds Privacy (global "Hide home airport", On by default; default visibility; home airport; default trim) and **About**, with the disclaimer "**Not for navigation.** Flyby is a personal flight journal. It isn't a certified logbook, and it isn't for navigation, flight planning or any operational use. Recorded altitudes, speeds and routes are approximate." (`png/19`, id `about.disclaimer`).
- Accessibility identifiers: `tab.home`, `tab.explore`, `tab.record`, `tab.flights`, `tab.profile`.

## Changelog
- **v0.3.2 (Oct 13, 2026):** adopted the PR #14 implementation as spec (design review `review-pr13-14.md`, L1). `.tabItem` is used on all OS versions (the iOS 18+ `Tab(...)` path was dropped), Record is intercepted in the selection-binding setter (instead of `onChange` revert), ids are installed via `TabBarAccessibilityIdentifiers`, and the Record tint is baked into the image. Tab order, symbols and ids `tab.home/explore/record/flights/profile` are unchanged.
- v0.3.1: QA follow-ups N1–N6 and PM trims.
