# Spec: Empty, loading & error states (v0.3.1, provisional)

References: `png/15-state-home-empty.png`, `png/16-state-flights-map-states.png`, `png/17-state-log-import-error.png`, `png/18-state-share-photos-denied.png`, `png/20-state-components.png`

## EmptyStateView (component)
- Built on `ContentUnavailableView` (iOS 17): symbol in a 64 pt `primarySoft` tile (`primary` glyph), title (`.title3` bold), body (`.subheadline`, `label2`, ≤ 2 sentences), **one** primary action (prominent capsule, ≥ 44 pt), and an optional secondary link.
- Lives inside a solid `surface` card or full-screen. Never on glass.
- id `empty.state`. VoiceOver reads title, then body, then the action as a button.
- Errors are **inline text + `exclamationmark.triangle` (or a contextual symbol) in `danger`, with a 1.5 pt `danger` outline on the card**. Never color alone, never a modal alert (except destructive confirms).

## Cases and copy
| Case | Where | Symbol | Title / body | Action |
|---|---|---|---|---|
| New pilot, no flights | Home (journal) | `airplane` | "Log your first flight" / "Enter a flight by hand or import a GPX or KML track. It stays private unless you choose otherwise." Summary card shows `0.0 h`, `0`, empty ring | **Log a Flight** (opens the Record sheet) · link "Import GPX or KML" |
| No flights | Flights tab | `book.closed` | "No flights yet" / "Logged and imported flights appear here, grouped by month." | Log a Flight |
| No filter/search matches | Flights tab | `book.closed` | "No flights match" / "Try another filter or search term." | Clear filters |
| Profile zero stats | Profile | — | Tiles show `0` in `label2`; "Achievements appear after your first flight." | — |
| Snapshot loading | Feed, Home, Flights, recap preview | — | `surface2` placeholder with a 1.2 s shimmer (static under Reduce Motion); text and stats render immediately | — |
| Snapshot failed | same | `arrow.clockwise` / `map` | "Map couldn't load" | Tap to retry (whole thumbnail is the button, 72 pt) |
| No track, airports known | anywhere a map is shown | — | Dashed great-circle line + pill **"Approximate route (not flown track)"** | — |
| No track and no airports (< 2 valid points) | same | `map` | "Route unavailable" / "No track and no known airports", hatched placeholder | — |
| GPX/KML import failed | Log a Flight | `exclamationmark.triangle` | "Couldn't import "<file>"" / "The file has no usable track points (0 of 312 valid). Nothing was changed." | Choose file · Enter manually |
| Import partial | Log a Flight | `exclamationmark.triangle` (`warning`) | "Imported with warnings" / "498 of 512 points kept. 14 were invalid (out of range or 0,0) and skipped." | — |
| Unsupported file / too large (> 20 MB) | Log a Flight | same | "This file type isn't supported. Use GPX or KML." / "This file is too large (max 20 MB)." | Choose file |
| Airport not found | Airport search | `magnifyingglass` | "No airport matches "KXYZ"" / "Check the ICAO or FAA code, or search by airport or city name." | Search by name instead |
| Required fields missing | Log a Flight | `exclamationmark.triangle` | Inline under the section: "Add From and To, or import a track, to save." Save is disabled (`label3`) | — |
| Recap export failed | Share | `exclamationmark.triangle` | "Couldn't create the image" / "Your flight is safe." | Try again |
| Photos permission denied | Share → Save | `photo` | "Flyby can't save to Photos" / "Allow "Add Photos Only" in Settings, or share the image instead." | Open Settings (`UIApplication.openSettingsURLString`) · Share instead |
| Offline *(post-Sprint 1, with Supabase. Don't build in Sprint 1: there's no networking or sync yet)* | any list | `wifi.slash` | Draft copy for later: "You're offline. Showing flights saved on this iPhone." Don't promise syncing until sync exists | — |

Copy is in plain English, never blames the user, and always says what happens to their data ("Nothing was changed", "Your flight is safe").
