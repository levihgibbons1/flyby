# Spec: Flight Detail (v0.2 Skyglass, provisional)

Reference: `png/03-flight-detail.png`

- **Map (full-bleed, top ~470 pt):** Strava-style activity map (see `maps.md`).
  - Basemap: `.mapStyle(.standard(elevation: .realistic, emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: false))` with map controls hidden.
  - Track: two `MapPolyline`s, a 9 pt white casing under a 5 pt solid Flyby Blue `#0A63DB` route, with round cap and join and a soft shadow.
  - Markers: the start dot (white with a blue ring) and the end dot (white with a navy core) are `Annotation`s. The arrival dot pops in after the draw-on.
  - The altitude gradient is an optional toggle.
- When no track exists, a dashed great-circle line is labeled **"Approximate route"** (MVP AC4.3).
- **Glass controls (top):** back (40 pt `.buttonStyle(.glass)`), and a share + more cluster in one glass capsule (`GlassEffectContainer`). A soft scroll-edge fade keeps the status bar legible.
- **Glass pills over the map:** VisibilityPill (e.g. Followers) and, for the owner, "Home zone hidden when shared", with a dashed privacy-zone ring around the home field.
- **Floating glass sheet** (system sheet, medium detent, inset 8 pt, ≈44 pt corners): grabber → `KSQL → KTVL` (SF Mono 24) + date → names · type · tail → 6 StatTiles (Flight, Distance, Max alt, Block, Avg GS, Max GS) → Profile chart card (altitude area, dashed gold GS, terrain silhouette, scrub capsule `11,500 ft · 178 kt · 0:32`) → disclaimer. Dragging to the large detent reveals notes and photos.
- **Disclaimer:** `info.circle` + "Recorded track for your journal · Not for navigation", caption2 in `label2` (on glass), centered. Never a banner or modal.
- No ownship, live position, ETA, or "fly to" actions.
- VoiceOver: map = "Route from San Carlos to Lake Tahoe, 135 nautical miles"; chart has an Audio Graph and a summary.
- Performance: simplify the track for the polyline; don't rebuild the map on scroll (MVP AC4.5).
