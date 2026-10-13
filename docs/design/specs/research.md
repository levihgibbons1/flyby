# Research notes for v0.2 (Oct 13, 2026)

## Apple Liquid Glass (iOS 26)
Sources: Apple "Adopting Liquid Glass" (developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass), "Liquid Glass" technology overview, HIG "Tab bars", WWDC25 sessions 219 "Meet Liquid Glass" and 323 "Build a SwiftUI app with the new design".
- A dynamic material that combines the optical properties of glass with fluidity. It forms a **distinct functional layer for navigation and controls** that floats above content.
- Standard bars, sheets, popovers and controls adopt it automatically. **Remove custom backgrounds** on bars and toolbars so system effects (incl. scroll-edge effect) work.
- Tab bar floats above content and can minimize on scroll: `.tabBarMinimizeBehavior(.onScrollDown)`.
- Small elements (nav bars, tab bars) flip light/dark based on the content behind them; large ones adapt without flipping.
- Variants: Regular (adaptive, default) and Clear (needs dimming over bright content).
- Tint **sparingly**, for primary actions only; put brand color in the content layer.
- Avoid overusing glass on custom controls. Group custom glass in `GlassEffectContainer` (performance + morphing via `glassEffectID`). Use `.interactive()` for tappable glass.
- Buttons: `.buttonStyle(.glass)` (secondary) and `.buttonStyle(.glassProminent)` (primary).
- HIG tab bars: "Use a tab bar to support navigation, not to provide actions"; short labels, SF Symbols (filled preferred).
- Implication: Record (an action) is a tab per the founder. We intercept its selection to present a sheet (see `navigation.md`).

## "Flightdeck": verified, but ambiguous
Two App Store apps carry the name:
1. **FlightDeck – Flight Tracker** (developer Attracts, tryflightdeck.com; listed 2026; iOS 18+, subscription). A live flight tracker: every plane on a map, decoded ACARS cockpit messages, Lock Screen tracking, weather, NOTAMs and FAA status. Reviews call the UI pretty but not yet polished.
2. **FlightDeck EFB** (App Store id1592153352). A digital kneeboard for pilots: checklists, one-tap flight time recording, METAR/TAF, notepad, documents, reminders, GDL90 traffic, EFIS.

**Open question for the founder:** which one was the reference? Borrowed either way: map-first layouts with floating panels and plain-English data (tracker), one-tap Out/Off/On/In time stamping (EFB). Explicitly **not** borrowed: live tracking, traffic and EFIS, since Flyby is not for navigation.

## Flighty / Strava (unchanged)
- Flighty: calm, dense, beautiful numerals, color as signal, recap moments.
- Strava: activity card (map + 3 stats + kudos), achievements, privacy zones.

## Strava activity map style (researched Oct 13, 2026)
- **Basemap:** muted and desaturated. Light gray land, soft blue-gray water, hillshade and faint contours, secondary roads and labels de-emphasized. Strava's own styles add winter/satellite/heatmap layers.
- **Route:** one bold, saturated polyline (Strava orange) with round joins and a subtle shadow, so it reads at thumbnail size. It optionally carries gradient coloring by pace, HR or elevation.
- **Markers:** small circular start (green) and finish (checkered/red) markers with white borders. Privacy zones hide the start and end of the line with no visible marker.
- **Feed:** the map is the biggest element of an activity card, edge-to-edge, with stats directly above it. Profile and list views use small square thumbnails.
- **What Flyby borrows:** the quiet-base/loud-route hierarchy, the casing and shadow, the dot markers, map-heavy cards and compact thumbnails.
- **What Flyby changes:**
  - Flyby Blue `#0A63DB` with a white casing instead of orange
  - a blue-ring start dot and a navy end dot instead of green/red
  - no heatmaps or segments on the map
  - a radial route fade instead of an abrupt cut at the privacy radius
  - MapKit `.muted` with POIs excluded instead of a custom Mapbox style
- Implementation notes are in `maps.md`.
