# Spec: Accessibility (v0.3.1, provisional)

Covers QA F5–F9. Targets: WCAG 2.2 AA in both modes, Dynamic Type to **AX3 fully laid out** (AX4–AX5 scroll and must not truncate), VoiceOver, Reduce Motion, Reduce Transparency, Increase Contrast.

## 1. Hit targets (F5)
- **Minimum 44×44 pt hit area** for everything tappable. The visual can be smaller: glass chrome buttons are drawn at 40 pt and get `.frame(minWidth: 44, minHeight: 44).contentShape(.rect)` (built into `flybyGlassButton`). See the dashed boxes in `png/21`.

| Control | Visual | Hit area |
|---|---|---|
| Back / close / share / more (glass) | 40 pt circle, or 40 pt slots in a capsule | 44×44 each; the share | more capsule is two separate 44 pt targets |
| Swap From/To (Log) | 40 pt | 44×44 |
| Trim stepper (Log) | 84×28 segmented | Use system `Stepper` (44 pt tall row). The mock segment is visual only |
| Template chips (Share) | 44 pt capsule (raised from 32) | 44 |
| Filter chips (Flights) | 32 pt capsule | 44 pt via vertical padding/contentShape |
| Visibility radio cards | ≥ 72 pt | full card |
| Toggles, list rows | system | ≥ 44 |
| Start/end dots, map annotations | 14–15 pt | **not interactive** (decorative; the map reads as one element) |
| Snapshot retry thumbnail | 72 pt | full thumbnail |

Proposed AC: Accessibility Inspector audit with no "Hit area is too small" warnings on Home, Flights, Log, Flight Detail and Share.

## 2. Contrast over glass and maps (F6)
**Token `mapScrim`:** `bg` at **60%** (light) / **70%** (dark), drawn as a plate under every glass element that sits on a map (Flight Detail controls and pills, recap map chips). On top of that, glass uses `glassStrong` (white 74% / `#1E283A` 72%). Text on glass over maps: `label`, `label2`, or `primary` only (no `label3`).

Measured worst case: the text sits over the darkest (light mode) or brightest (dark mode) map pixel, with no blur averaging.

| Background under glass | Without scrim (v0.2 regular glass) label / label2 / primary | **With scrim + glassStrong** label / label2 / primary |
|---|---|---|
| Light · route `#0A63DB` | 9.7 / **3.9 ✗** / **2.9 ✗** | **15.9 / 6.4 / 4.7** |
| Light · end dot `#1E3A8A` | 8.3 / **3.3 ✗** / **2.4 ✗** | **15.5 / 6.2 / 4.5** |
| Light · water `#D4DFE8` | 16.6 / 6.7 / 4.9 | 18.0 / 7.2 / 5.3 |
| Dark · white casing / road `#FFFFFF` | **2.9 ✗ / 1.4 ✗ / 1.2 ✗** | **11.3 / 5.5 / 4.7** |
| Dark · route `#4DA3FF` | 5.5 / 2.7 ✗ / 2.3 ✗ | 12.6 / 6.2 / 5.3 |
| Dark · end dot `#A5C8FF` | 4.2 / 2.0 ✗ / 1.7 ✗ | 12.0 / 5.9 / 5.0 |

- **Flight Detail sheet** (`glassStrong`, over the map's lower edge): the disclaimer in `label2` measures ≥ 6.2 light / ≥ 5.5 dark with the scrim, and ≥ 5.1 / ≥ 2.7 without it. So the sheet always gets the scrim in Dark mode.
- **Map labels:** SF Mono Bold 12 with a 3 pt `mapLand` halo (`paint-order: stroke`). ICAO in `label`: 16.4 (light) / 15.5 (dark). Region labels ("BAY AREA") moved from `label3` (4.4, ✗) to `label2`: 6.6 / 7.6.
- **Increase Contrast:** glass → `glassStrong` + 1 pt `sep` border; scrim → 80% (dark worst case 12.4 / 6.1 / 5.2). **Reduce Transparency:** glass and scrim → solid `surface`.
- Status bar over the map: the 110 pt `bg` 85% → 0 gradient gives `label` ≥ 13.5:1 at the clock (measured over the route and the end dot).

## 2b. iOS 17/18 fallback contrast (N2)
The iOS 17/18 branch of `flybyGlass` uses **`MapScrim` + `.thickMaterial`** on maps, and **`.regularMaterial`** for chrome that isn't over a map. `.ultraThinMaterial` and `.thinMaterial` are banned under text.

**Method:** worst case, with the text over the darkest (light) or brightest (dark) map pixel and no blur averaging. Materials are modeled as flat fills: light = white at 35 / 60 / 78% (ultraThin / regular / thick); dark = `#1C1C1E` at 45 / 70 / 85%. Scrim = `bg` 60% (light) / 70% (dark). These are **modeled values**; confirm them on the iOS 17 simulators (SE, 15 Pro Max) by sampling screenshot pixels behind the text and with Accessibility Inspector.

Each cell is label / label2 / primary.

| Under the surface | `.ultraThin` (v0.3, rejected) | `.ultraThin` + scrim (v0.3, rejected) | `.regular` + scrim | **`.thick` + scrim (chosen for maps)** |
|---|---|---|---|---|
| Light · route `#0A63DB` | 6.5 / **2.6 ✗** / **1.9 ✗** | 12.3 / 5.0 / **3.6 ✗** | 14.6 / 5.9 / **4.3 ✗** | **16.4 / 6.6 / 4.8** |
| Light · end dot `#1E3A8A` | 4.8 / **1.9 ✗** / **1.4 ✗** | 11.3 / 4.5 / **3.3 ✗** | 13.9 / 5.6 / **4.1 ✗** | **15.9 / 6.4 / 4.7** |
| Light · water `#D4DFE8` | 15.4 / 6.2 / 4.5 | 16.9 / 6.8 / 5.0 | 17.6 / 7.1 / 5.2 | **18.1 / 7.3 / 5.3** |
| Dark · white casing `#FFFFFF` | **2.6 ✗ / 1.3 ✗ / 1.1 ✗** | 10.0 / 4.9 / **4.2 ✗** | 12.5 / 6.1 / 5.2 | **14.0 / 6.9 / 5.8** |
| Dark · route `#4DA3FF` | 5.4 / **2.7 ✗** / **2.3 ✗** | 12.7 / 6.2 / 5.3 | 14.1 / 6.9 / 5.9 | **14.8 / 7.3 / 6.2** |
| Dark · end dot `#A5C8FF` | 4.0 / **1.9 ✗** / **1.6 ✗** | 11.6 / 5.6 / 4.8 | 13.4 / 6.5 / 5.6 | **14.5 / 7.1 / 6.0** |

Worst case with `.thickMaterial` + scrim: **light 15.9 / 6.4 / 4.7** and **dark 14.0 / 6.9 / 5.8**. Every text color passes 4.5:1, including the Flight Detail disclaimer (`label2`: ≥ 6.4 light / ≥ 6.9 dark) and the blue "Followers" pill.

**`.regularMaterial`** (not on maps) sits over `bg`/`skyWash` only. Over the darkest sky-wash stop (`#DCEBFF` light / `#12213C` dark) it measures 17.4 / 7.0 / 5.1 (light) and 15.4 / 7.5 / 6.4 (dark). Never place `primary` text on `.regularMaterial` over a map; light primary measures only 4.1–4.3 there.

**Increase Contrast** (iOS 17): scrim → 80% plus a 1 pt `sep` border. **Reduce Transparency:** solid `surface` (the system also makes materials opaque).

## 3. Recap export style (F6)
- Recaps render through `ImageRenderer` with a **fixed** `colorScheme` and `dynamicTypeSize(.large)`. They **never** follow the device appearance or text size.
- Default: **Light** (Skyglass, Window Seat, Logbook Card).
- Optional **Night** style, available **only on the Logbook Card** (PM scope; `png/24`). Skyglass and Window Seat export Light only: `bg #0A0F1A`, dark muted basemap, route `#4DA3FF` on a white casing, text `#F2F5FA` (17.5:1 on `#0A0F1A`), secondary `#A3AEC2` (8.6:1), disclaimer `#A3AEC2`.
- The Share preview shows exactly the exported image, even when the app is in Dark mode.

## 4. Dynamic Type (F7)
| Screen | Default → AX3 behavior |
|---|---|
| Flight Detail | The sheet opens at the **large** detent at AX1+. StatTiles reflow 3 → 2 → 1 columns (`ViewThatFits`). Route header `KSQL → KTVL` wraps to two lines (arrow stays with the arrival). The chart keeps a fixed height, and the scrub capsule moves above the chart. Glass pills stack vertically |
| Log a Flight | ICAO fields stack From above To (the swap button moves to the trailing edge). The **Out/Off/On/In row goes 4-across → 2×2 → a list** of 4 rows. The visibility picker goes from 3 cards to a vertical list. The import banner text wraps; the icon stays 40 pt |
| Home summary card | Ring above the stats at AX1+; stats go to 1 column at AX3 |
| Feed / FlightCard | Stats 3 → 1 column; the map keeps its aspect; the title wraps to 3 lines max with no truncation of numbers |
| Flights rows | The thumbnail stays 72 pt; text wraps under it at AX3 |
| Tab bar | System large-content viewer on long-press |
| **Recaps** | **Excluded from Dynamic Type** (fixed render, see §3). The Share screen's own controls do scale |

## 5. VoiceOver (F8)
- **FlightCard / FlightRow:** `.accessibilityElement(children: .combine)`, with the label "Flight, San Carlos to Lake Tahoe, Saturday September 19, Cirrus SR22, 58 minutes, 135 nautical miles, max altitude 11,500 feet recorded. Visibility: Followers." The map snapshot is `.accessibilityHidden(true)`. Actions: Open, Share (custom actions).
- The disclaimer is real text and **is read**, never `.accessibilityHidden`.

| Screen | Element | Label | Value | Hint / trait |
|---|---|---|---|---|
| Flight Detail | Back | "Back" | — | button |
| | Share | "Share recap" | — | button |
| | More | "More options" | — | button |
| | Map | "Route map, San Carlos to Lake Tahoe, 135 nautical miles" (or "Approximate route, not the flown track" / "Route unavailable") | — | image; not interactive in VoiceOver |
| | Visibility pill | "Visibility" | "Followers" | "Double-tap to change." button |
| | Home-hidden pill | "Home airport hidden when shared" | — | static text |
| | Stat tile | "Max altitude, recorded" | "11,500 feet" | — |
| | Profile chart | "Recorded altitude and ground speed profile, approximate" | summary sentence | Audio Graph (`AXChartDescriptor`); terrain "illustrative" |
| | Disclaimer | "Recorded track for your journal. Not for navigation." | — | static text |
| Log a Flight | Cancel / Save | "Cancel" / "Save flight" | — | Save says "dimmed" until it's valid; when dimmed, the hint names the missing fields |
| | Import | "Import GPX or KML" | — | "Fills route, times and altitude from a track file." |
| | From / To | "From airport" / "To airport" | "KSQL, San Carlos" | text field |
| | Swap | "Swap departure and arrival" | — | button |
| | Out/Off/On/In | "Off time" | "16:11 PDT" | "Double-tap to stamp the current time. Swipe up or down to adjust." adjustable |
| | Trim stepper | "Trim start and end" | "1.0 nautical miles" | adjustable, 0.5 nm steps |
| | Visibility picker | "Visibility" (radio group) | "Private, selected, default" | — |
| | Home airport note | "Home airport hidden when shared, from your privacy setting" | — | static text. (The per-flight toggle is deferred past Sprint 1) |
| Share | Preview | "Recap preview: Over the Sierra to Tahoe. Bay Area to KTVL, 58 minutes, 135 nautical miles. Home airport hidden." | — | image |
| | Template chips | "Template" | "Skyglass, 1 of 3" | selected trait |
| | Toggles | "Hide home airport" / "Show tail number" | On / Off | switch; hint "This share only." |
| | Trim | "Trim start and end" | "1.0 nautical miles" | adjustable |
| | Save / Share | "Save image to Photos" / "Share to Stories" | — | button |
| Tab bar | Record | "Record a flight" | — | "Opens the log sheet." |

## 6. Accessibility identifiers (F9)
Convention: `area.element[.qualifier]`.

| Area | Ids |
|---|---|
| Tabs | `tab.home`, `tab.explore`, `tab.record`, `tab.flights`, `tab.profile` |
| Flight Detail | `detail.map`, `detail.back`, `detail.share`, `detail.more`, `detail.visibility`, `detail.disclaimer`, `detail.chart`, `detail.stat.<flight|distance|maxAlt|block|avgGS|maxGS>` |
| Recap / Share | `recap.preview`, `recap.template.<skyglass|window|square>`, `recap.style.<light|night>` (style picker shown on the Logbook Card only), `recap.toggle.hideHome`, `recap.toggle.trim`, `recap.toggle.tail`, `recap.save`, `recap.share`, `recap.disclaimer`, `recap.error` |
| Log a Flight | `log.save`, `log.cancel`, `log.import`, `log.import.error`, `log.field.dep`, `log.field.arr`, `log.field.date`, `log.field.aircraft`, `log.field.tail`, `log.time.<out|off|on|in>`, `log.visibility` (renamed from `visibilityPicker`), `log.visibility.private|followers|public`, `log.privacyNote`, `log.trim`, `log.disclaimer` |
| Lists | `flights.list`, `flights.row.<id>`, `home.recent`, `home.summary` |
| States | `empty.state`, `empty.action`, `map.placeholder`, `map.retry` |
| Settings | `settings.hideHome`, `settings.defaultVisibility`, `settings.homeAirport`, `settings.trim`, `about.disclaimer` |
