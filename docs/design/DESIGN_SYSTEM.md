# Flyby Design System: "Skyglass" (v0.3, provisional)

> Local draft, Oct 13, 2026. **Replaces v0.1 "Contrail"** (dark), per founder feedback. Scope is provisional. All data in the mockups is **sample data**.
> Visual reference: `proposal.html` (open in a browser) and `png/`. Research notes: `specs/research.md`.
> **v0.3** addresses QA review `qa/design-review-sprint1.md` (F1–F15). **Deployment target: iOS 17.0.** New specs: `specs/platform-fallbacks.md`, `specs/accessibility.md`, `specs/states.md`.

## 1. Direction
| | **A · Skyglass** (recommended) | B · Contrail (v0.1, retired) |
|---|---|---|
| Mood | Light-first and airy. White surfaces on a soft sky wash, one Flyby Blue, a crisp blue route with a white casing; navigation and map controls float on iOS 26 **Liquid Glass** | Dark Ink, glowing route, amber accents |
| Why | Matches what the founder liked (light Home Journal + Pilot Profile); native to iOS 26; content stays the hero | Read as heavy and nocturnal; off-brief |

What carries over from v0.1: optional altitude-tinted routes (Flight Detail toggle), rounded tabular numerals, SF Mono codes, the privacy model, the not-for-navigation stance.

## 2. Liquid Glass usage (from Apple's guidance)
> **Platform rule (F1):** everything in this section is iOS 26 (and `Tab(...)` / the zoom transition are iOS 18). Feature views call only the DesignSystem wrappers `flybyGlass()`, `flybyGlassButton()`, `FlybyGlassGroup`, `flybyTabBarMinimizeOnScroll()` and `flybyZoomSource/Destination`. They gate with `#available` and fall back to `.ultraThinMaterial` (+ `mapScrim` on maps), `.bordered/.borderedProminent`, the classic `.tabItem` TabView and a standard push on iOS 17. See `specs/platform-fallbacks.md`.

- Glass is a **functional layer for navigation and controls** that floats above content. Content itself (flight cards, lists, forms) stays on solid `surface`.
- Use system components so glass is real: `TabView` (floating glass tab bar, `.tabBarMinimizeBehavior(.onScrollDown)`), toolbars, sheets, `.buttonStyle(.glass)` and `.glassProminent`. **No custom backgrounds on bars.**
- Custom glass only for: the floating stats sheet/panel over the Flight Detail map, map control clusters, and filter chips (`.glassEffect(.regular, in:)`, grouped in `GlassEffectContainer`, morphing via `glassEffectID`). Add `.interactive()` only to tappable glass.
- **Tint sparingly:** Flyby Blue only on Record and primary buttons.
- Use the Regular variant. Clear glass only over media, with a dimming layer, and never for text in recaps.
- Accessibility: Reduce Transparency → glass becomes solid `surface`; Increase Contrast → 1 pt `sep` border on glass. Text on glass uses `label`/`label2` only.

## 3. Color tokens (Light primary · Dark variant)
| Token | Role | Light | Dark | Contrast L / D |
|---|---|---|---|---|
| `bg` (Cloud) | App background | `#F5F8FC` | `#0A0F1A` | — |
| `skyWash` | Top-of-screen gradient behind glass | `#DCEBFF → bg` | `#12213C → bg` | Decorative |
| `surface` (Cloud White) | Content cards, sheets | `#FFFFFF` | `#141B28` | — |
| `surface2` | Grouped fills, inputs | `#EEF3F9` | `#1C2536` | — |
| `glass.regular` | Tab bar, floating controls (not over maps) | system; mock = white 58% + blur 22 + sat 180% + 1 pt highlight | system; mock = `#222C40` 52% | Over busy content it fails (label2 3.9 light / 1.4 dark), so over maps use the next two rows |
| `glassStrong` | Sheets/panels and anything over a map or recap | white 74% | `#1E283A` 72% | see below |
| `mapScrim` | Plate under every glass element on a map | `bg` 60% | `bg` 70% | Measured worst case with glassStrong: light label 15.5 / label2 6.2 / primary 4.5; dark 11.3 / 5.5 / 4.7 (`specs/accessibility.md` §2) |
| `label` | Primary text | `#0B1220` | `#F2F5FA` | 17.6 / 17.5 |
| `label2` | Secondary text, units | `#4A5568` | `#A3AEC2` | 7.1 / 8.6 |
| `label3` | Tertiary (not on glass, not for map labels) | `#647089` | `#7D89A0` | 4.7 / 4.9 (4.4 on mapLand, so region labels use `label2`) |
| `primary` (Flyby Blue) | Actions, links, selection, Record | `#0A63DB` | `#4DA3FF` | 5.5 / 6.6; on-primary 5.5 / 7.2 |
| `onPrimary` | Text on primary | `#FFFFFF` | `#03112A` | — |
| `sky` | Decorative fills (not text on white; `#007AFF` would be only 4.0) | `#4BA3FF` | `#4DA3FF` | — |
| `route` + `routeCasing` | Track line over a white casing (Strava-style activity map) | `#0A63DB` + white | `#4DA3FF` + white | 4.8 / 6.4 vs land, 4.1 vs water (non-text ≥ 3:1) |
| `routeEnd` | Arrival dot core | `#1E3A8A` | `#A5C8FF` | 9.1 vs land |
| `altLow / altMid / altHigh` | Altitude ramp, track + chart | `#8CCBFF / #2F80ED / #1E3A8A` | `#9BD3FF / #4DA3FF / #A5B4FC` | Decorative |
| `gold` | Achievements; ground-speed line in charts | `#F2A93B` fill, `#9A5B00` text | `#F2A93B` | 5.4 text |
| `success / warning / danger` | States | `#137A3A / #9A5B00 / #C2261F` | `#4ADE80 / #FBBF24 / #FF6B6B` | 5.4 / 5.4 / 5.9 |
| `mapLand / mapWater` | Muted activity basemap (mockups; MapKit `.muted` in app) | `#EEF0F2 / #D4DFE8` | `#171D27 / #0C141F` | Low contrast on purpose |
| `mapRoad / mapRoadCasing / mapHill / mapContour` | Basemap detail (mockups only) | white / ink 10% / ink 3.5% / ink 7% | white 10% / black 25% / white 2.5% / white 5% | — |

Visibility is always icon + label: Private (`lock.fill`, label2) · Followers (`person.2.fill`, primary) · Public (`globe.americas.fill`, success).

## 4. Typography
Unchanged from v0.1. **SF Pro** for words, **SF Pro Rounded Semibold + `.monospacedDigit()`** for stats, **SF Mono** for ICAO codes, tail numbers and coordinates. Everything maps to iOS text styles. Every screen is fully laid out at **AX3**; AX4–5 scroll without truncation. Stat grids reflow 3 → 2 → 1 columns, the Out/Off/On/In row goes 4 → 2×2 → list, and the Flight Detail sheet opens at the large detent at AX1+. **Recaps are excluded** (fixed render). See `specs/accessibility.md` §4.

| Token | iOS style | Font / weight | Size / leading (Large) |
|---|---|---|---|
| `statHero` | custom, `relativeTo: .largeTitle` | SF Pro Rounded Semibold, tabular | 48 / 52 |
| `largeTitle` | `.largeTitle` | SF Pro Display Bold | 34 / 41 |
| `title2` | `.title2` | SF Pro Display Bold | 22 / 28 |
| `statValue` | `.title2` rounded | SF Pro Rounded Semibold, tabular | 22 / 26 |
| `routeCode` | `.title3` monospaced | SF Mono Semibold | 20 / 25 |
| `headline` / `body` | `.headline` / `.body` | SF Pro Text Semibold / Regular | 17 / 22 |
| `subhead` | `.subheadline` | SF Pro Text Regular | 15 / 20 |
| `statLabel` | `.caption` | SF Pro Text Medium | 12 / 16 |
| `eyebrow` | `.caption2`, uppercase, tracking 0.6 | SF Pro Text Semibold | 11 / 13 |
| `tail` / `coord` | `.footnote` monospaced | SF Mono Medium | 13 / 18 |

Units render at about 50% of the value size in `label2`. Formats: `h:mm` durations, decimal logbook hours, nm, ft MSL, kt GS (metric is a user setting).

## 5. Spacing, radius, elevation
- **Spacing:** `4 · 8 · 12 · 16 (margin) · 24 · 32 · 48`
- **Radius (`.continuous`, concentric with the display):** chip/button capsule · sm 10 · md 14 · tile 18 · card 24 · panel 30 · inset sheet ≈ 44 (system)
- **Tab bar:** system floating glass capsule. Mockups show it 62 pt tall, 14 pt side inset, 24 pt from the bottom.
- **Elevation:** `elev.card` = y1 b2 5% + y6 b20 6% navy (solid cards); `elev.glass` = y10 b30 13% navy + inner 1 pt highlight (mock approximation of system glass).
- **Min hit target 44×44 pt**, even when the visual is smaller (40 pt glass buttons get `.frame(minWidth: 44, minHeight: 44).contentShape(.rect)`). Map dots aren't interactive.
- Flight Detail map height = `clamp(container × 0.55, 280, 520)`. Snapshots are sized from the measured width × aspect × `displayScale`.

## 6. Core components
| Component | Layer | Notes |
|---|---|---|
| FlightCard / FlightRow | Content (solid) | Activity-map snapshot (trimmed for non-owners); feed posts put 3 stats above an edge-to-edge 212 pt map; rows use a 72 pt thumbnail (3.2 pt route). SF Mono route, VisibilityPill, date · aircraft |
| StatTile | Content (solid; 70% white when inside a glass sheet) | eyebrow + statValue + unit |
| VisibilityPill / VisibilityPicker | Content | Picker = 3 radio cards, Private preselected ("Default") |
| Glass controls | Glass | 40 pt visual / **44 pt hit**, via `flybyGlassButton()` (iOS 26 `.glass`, iOS 17 `.bordered` circle): back, share, more, close. Clustered share/more = one capsule with two 44 pt targets; `mapScrim` when over a map |
| Primary button | Glass prominent | Capsule 50 pt, Flyby Blue (`.glassProminent` + tint; `.borderedProminent` on iOS 17) |
| Glass panel / sheet | Glass | Flight Detail stats + chart sheet floating over the map (medium detent) |
| Chips | Glass group | Filters, recap template picker; morph in `GlassEffectContainer` (iOS 26) or cross-fade (17/18); 44 pt hit |
| TabBar | System glass | 5 tabs, see §7 |
| Disclaimer | Content | `info.circle` + caption2, always containing the exact substring **"Not for navigation"**; read by VoiceOver |
| EmptyStateView | Content (solid) | `ContentUnavailableView`-based: symbol tile, title, body, one action (`specs/states.md`); id `empty.state` |
| InlineError | Content | `exclamationmark.triangle` (or a contextual symbol) + text in a card with a 1.5 pt `danger` outline; never color alone |
| MapPlaceholder | Content | Loading shimmer / "Map couldn't load · Retry" / hatched "Route unavailable" / dashed "Approximate route (not flown track)" |

## 7. Navigation (founder kickoff; matches MVP-PLAN.md D2)
**Home · Explore · Record · Flights · Profile**

| Tab | SF Symbol | Purpose | A11y id |
|---|---|---|---|
| Home | `house.fill` | Pre-social: journal (year summary + recent flights). Post-social: Following ⇄ You | `tab.home` |
| Explore | `globe.americas.fill` | Airports visited/wishlist, airport pages; discovery, not planning | `tab.explore` |
| Record | `plus.circle.fill`, tinted Flyby Blue | **Center tab.** Opens the Log a Flight sheet; never records live position | `tab.record` |
| Flights | `book.closed.fill` | The user's logbook list: search, filters, totals, grouped by month | `tab.flights` |
| Profile | `person.crop.circle.fill` | Totals, logbook stats, aircraft, achievements, settings & privacy | `tab.profile` |

HIG note: tab bars are for navigation, not actions. Record is a real `Tab` whose selection is intercepted to present the sheet; the previous tab stays selected.

## 8. Principles
1. **Journal, not navigation.** No live position, ownship, guidance, ETA or planning UI. A small "Not for navigation" line on Flight Detail, the Log save footer, every recap (both styles) and Profile → Settings → About. About also says Flyby is not a certified logbook. Values are labeled recorded/entered and approximate; terrain is illustrative.
2. **Private by default.** Model and UI default to Private; visibility shows on every card.
3. **Privacy before pixels.** One global **Hide home airport** setting, **On by default**, that can be overridden per flight (optional) or per share (not persisted). Track trimming happens before any shared view or recap renders.
4. **Glass for chrome, white for content.** Color comes from content; tint only the primary action.
5. **Accessible by construction.** AA in both modes with measured glass-over-map values, 44 pt targets, AX3 layouts, VoiceOver tables and stable ids (`specs/accessibility.md`), Reduce Motion / Transparency / Increase Contrast.
6. **Robust geometry.** No force unwraps. Tracks need ≥ 2 valid points; coordinates are validated and antimeridian-safe (`specs/maps.md`).
7. **Recaps have a fixed style.** Light by default, optional Night. They never follow the system appearance.


## Activity maps
The look is Strava-inspired: a muted base with a loud route. The basemap is MapKit `.standard(emphasis: .muted, pointsOfInterest: .excludingAll)`. The route is solid Flyby Blue over a white casing: 5/9 pt on detail, 4.6/8.6 pt on cards, 3.2/6.4 pt on thumbnails, with round joins and a soft shadow. The start dot is white with a blue ring; the end dot is white with a navy core. Shared views have no start dot, the route fades out near home, and there's no zone ring. Full spec and MapKit code: `specs/maps.md`.

## Spec index (v0.3)
`specs/navigation.md` · `flight-detail.md` · `log-flight.md` · `maps.md` · `privacy-sharing.md` · `recaps.md` · `states.md` · `accessibility.md` · `platform-fallbacks.md` · `motion.md` · `screens.md` · `research.md`
