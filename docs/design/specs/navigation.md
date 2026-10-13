# Spec: Navigation & tab bar (v0.3 Skyglass, provisional)

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
  - **iOS 18+:** `Tab(_:systemImage:value:)` items. On iOS 26 this gives the floating Liquid Glass tab bar automatically.
  - **iOS 17:** the classic `.tabItem { Label(…) }.tag(TabID…)` with the same symbols, order and ids.
  - Use `.tint(Color.Flyby.primary)` on all versions.
  - `flybyTabBarMinimizeOnScroll()` applies `.tabBarMinimizeBehavior(.onScrollDown)` on iOS 26 only (the bar shrinks while scrolling down on Home, Explore and Flights). It's a no-op on 17/18.
- **Record is an action, not a destination.** It's a real tab (value/tag `.record`, on both the iOS 18 `Tab` and the iOS 17 `.tabItem` paths); `onChange(of: selection)` reverts to the previous tab and sets `showLog = true`, which presents the Log a Flight sheet (a glass sheet on iOS 26, the standard sheet on 17/18). The bar never shows an empty Record screen. This satisfies the 5-tab spec while respecting the HIG guidance that tab bars are for navigation.
- Record is the only tinted tab item. Selected tabs get the system glass "lens" highlight plus the primary tint.
- Home journal mode: large title "Home", "2026 so far" summary card (progress ring toward an hours goal, flights, airports, distance; "Only you" pill), "Recent flights" (3 compact rows with visibility pills), and an "All flights" link that switches to the Flights tab.
- Home social mode (later): large title "Home", `Following | You`, feed posts (author · time · aircraft · visibility, title, trimmed map, 3 stats, Tailwinds / comments / share).
- Achievements live in Profile (section + full gallery). They don't get a tab.
- Labels are always shown. Large-content viewer at accessibility sizes. Each tab item's hit area is ≥ 44 pt (system).
- Card → Flight Detail: zoom transition on iOS 18+ (`flybyZoomSource/Destination`), standard push on iOS 17.
- Profile → **Settings** (gear, 44 pt) holds Privacy (global "Hide home airport", On by default; default visibility; home airport; default trim) and **About**, with the disclaimer "**Not for navigation.** Flyby is a personal flight journal. It isn't a certified logbook, and it isn't for navigation, flight planning or any operational use. Recorded altitudes, speeds and routes are approximate." (`png/19`, id `about.disclaimer`).
- Accessibility identifiers: `tab.home`, `tab.explore`, `tab.record`, `tab.flights`, `tab.profile`.
