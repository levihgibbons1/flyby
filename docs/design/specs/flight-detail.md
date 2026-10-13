# Spec: Flight Detail (v0.3 Skyglass, provisional)

References: `png/03-flight-detail.png` (6.3"), `png/21-sizes-flight-detail-se-promax.png` (SE, Pro Max), `png/16`/`png/20` (map states)

- **Map (full-bleed):** height = `clamp(container × 0.55, 280, 520)` pt. That's 469 on 6.3", 367 on SE and 520 on Pro Max.
  - Strava-style activity map (see `maps.md`): `.mapStyle(.standard(elevation: .realistic, emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: false))`, with controls and annotation titles hidden.
  - Track: one `MapPolyline` pair per validated segment, a 9 pt white casing under a 5 pt Flyby Blue `#0A63DB` line with round cap and join and a soft shadow.
  - Start and end dots are non-interactive `Annotation`s. The arrival dot pops in after the draw-on.
  - The altitude gradient is an optional toggle.
- **Route states (F2):** render only `RouteDisplay`, with no force unwraps.
  - `.track`: ≥ 2 valid points.
  - `.approximate`: no usable track, airports known. Dashed great-circle line plus the pill **"Approximate route (not flown track)"** (AC4.3).
  - `.unavailable`: hatched placeholder, "Route unavailable".
- **Glass controls (top):** back, plus a share + more cluster in one capsule (`FlybyGlassGroup`). The visuals are 40 pt with **44×44 hit areas** (two separate 44 pt targets in the capsule). They use `flybyGlassButton()`:
  - iOS 26: `.buttonStyle(.glass)`
  - iOS 17/18: `.bordered` circle
  - Every glass element on the map gets the `mapScrim` plate (`flybyGlass(onMap: true)`).
  - A 110 pt `bg` 85% → 0 gradient keeps the status bar ≥ 13.5:1.
- **Glass pills over the map:** VisibilityPill (e.g. Followers). For the owner, also "Home airport hidden when shared", with a dashed privacy-zone ring around the home field (owner only).
- **Floating sheet:**
  - iOS 26: system glass sheet, medium detent, inset 8 pt, ≈ 44 pt corners.
  - iOS 17/18: standard sheet with `.ultraThinMaterial` + scrim.
  - SE: no inset, 22 pt top corners.
  - Contents, top to bottom:
    1. grabber
    2. `KSQL → KTVL` (SF Mono 24) + date
    3. names · type · tail
    4. 6 StatTiles: Flight, Distance, **Max alt · rec**, Block, **Avg GS · rec**, **Max GS · rec**
    5. **Recorded profile · approx.** chart card (altitude area, dashed gold GS, terrain silhouette captioned "Terrain illustrative", scrub capsule `≈11,500 ft · 178 kt · 0:32`)
    6. disclaimer
  - Dragging to the large detent reveals notes and photos.
  - At AX1+ the sheet opens at the large detent (`accessibility.md` §4).
  - On SE (container < 700 pt tall) the chart is compact (66 pt) and the scrub capsule appears only while touching, so the disclaimer stays visible at the medium detent.
- **Data provenance (F13):**
  - Values from a GPX/KML track are labeled **"rec"** (recorded), and the chart reads "Recorded profile · approx."
  - Manually entered values are labeled **"Entered"** (e.g. "Max alt · entered").
  - Without a track, the speed and altitude tiles show "—" with the caption "Not recorded".
  - Block and Flight come from the pilot's own times: personal journal, not a certified logbook.
- **Disclaimer:** `info.circle` + "Recorded track for your journal · Not for navigation", caption2 in `label2` on the glass sheet (≥ 6.2:1 light / ≥ 5.5:1 dark with the scrim), centered.
  - The exact substring "Not for navigation" is used everywhere.
  - It's read by VoiceOver. It's never a banner or modal. id `detail.disclaimer`.
- No ownship, live position, ETA, or "fly to" actions.
- **VoiceOver:** see the table in `accessibility.md` §5 (back, share, more, map, visibility pill, tiles, chart Audio Graph, disclaimer).
- **Ids:** `detail.map`, `detail.back`, `detail.share`, `detail.more`, `detail.visibility`, `detail.chart`, `detail.stat.*`, `detail.disclaimer`.
- **Transition:**
  - iOS 18+: zoom from the card (`flybyZoomSource` / `flybyZoomDestination`).
  - iOS 17: standard push.
- **Performance:** simplify the track for the polyline, and don't rebuild the map on scroll (MVP AC4.5).
