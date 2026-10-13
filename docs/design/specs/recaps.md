# Spec: Shareable flight recaps (v0.3.1 Skyglass, provisional)

References: `png/10-recap-story-skyglass-1080x1920.png`, `png/11-recap-story-window-seat-1080x1920.png`, `png/12-recap-square-logbook-1080x1080.png`, `png/24-recap-square-night-1080x1080.png`, `png/08-share-recap.png`, `png/18-state-share-photos-denied.png`, `png/23-sizes-share-se-promax.png`

Rendered with `ImageRenderer` at 1080×1920 (Story) and 1080×1080 (Post). The design grid is 360×640 / 360×360 pt at 3×.

| Template | Look | Content |
|---|---|---|
| **A · Skyglass** (Story) | Deep-to-pale sky gradient. A muted activity-map card (r30, white rim) carries the trimmed Flyby Blue route with a white casing. A strong frosted glass stats panel overlaps the card's lower edge | Title, pilot · aircraft, date, "Home field hidden", BAY AREA → KTVL, Flight time, Distance, **Max alt · recorded**, **Avg GS · recorded**, altitude sparkline |
| **B · Window Seat** (Story) | Muted activity map framed in an aircraft window (vignette and glare), white page. KPAO isn't the home field, so the start dot shows | KPAO → KMRY, names · type · "Tail hidden", 3 stats (Max alt · rec.) in a white card |
| **C · Logbook Card** (Post) | Map-forward muted activity map (top 58%) with a glass Flyby chip | BAY AREA → KTVL, type · date, 4 stats ("(rec.)" on altitude and speed), handle |
| **C · Logbook Card, Night** (Post; the **only** template with Night in Sprint 1) | Same layout on `#0A0F1A`, dark muted basemap, `#4DA3FF` route with a white casing | Same |

Rules
1. **Privacy is applied before render** (`privacy-sharing.md`). Share starts from the **global "Hide home airport" (On by default; there's no per-flight override in Sprint 1)** and the default trim (1.0 nm), which matches MVP AC6.4. Toggling in Share is a **this-share-only override**: it isn't saved to the flight or the global setting, and the caption reads "Your default: On · this share only". The preview updates live.
2. **Map treatment:**
   - The route always sits on a muted basemap (`MKMapSnapshotter`, `.muted`, `.excludingAll`), never bare on sky or photo.
   - 5–5.4 pt Flyby Blue over a white casing (+2.2 pt per side), round joins, soft shadow.
   - The end dot is navy; there's no start dot when trimmed.
   - Only a validated track with ≥ 2 points is drawn. Otherwise the recap uses the dashed "Approximate route (not flown track)" line, or omits the map card (`maps.md`).
3. **Fixed export style (F6):**
   - Rendered with `.environment(\.colorScheme, style == .night ? .dark : .light)` and `.dynamicTypeSize(.large)`. It **never** follows the device appearance or Dynamic Type.
   - The default is **Light**. **Night** is an explicit choice that's **offered only on the Logbook Card** (PM scope; `recap.style.night`). Skyglass and Window Seat export Light only, and their style picker is hidden.
   - The preview shows exactly the exported pixels.
4. One hero (the route), 4 facts max, date only (exact times off by default). Tail number off by default. Altitude and speed are labeled **recorded** (or "entered" for manual values).
5. **Glass** in recaps is always the strong frosted variant (≥ 74% white; Night `#1E283A` 72%), with the `mapScrim` plate on map chips. Never Clear glass under text.
   - Light: ink on frosted panel > 15:1; white on the deep-sky top 5.7:1.
   - Night: `#F2F5FA` on `#0A0F1A` 17.5:1, `#A3AEC2` 8.6:1.
6. Story safe areas: keep key text out of the top 220 px and bottom 260 px at 1080×1920. Post margin 72 px.
7. **Disclaimer:** "Not for navigation" (the exact substring) in caption2 (~27 px at 1080 wide), bottom row opposite the handle, on every template and style. Never more prominent than the handle. "Sample data" appears only in mockups. id `recap.disclaimer`.
8. Flyby mark (blue gradient app tile + wordmark) top-left; never over the route.

Share screen:
- **Layout:**
  - Live preview: 40% scale on SE, 60% on 6.3", 66% on Pro Max (`png/23`).
  - Template chips (44 pt). A Light / Night style control appears **only when the Logbook Card is selected**.
  - Toggles: Hide home airport, Trim start/end (`Stepper`), Show tail number.
  - Actions: **Save** (glass) and **Share to Stories** (prominent).
- **Photos permission (F14):** only **Save** requests add-only access (`PHPhotoLibrary.requestAuthorization(for: .addOnly)`), at the moment of saving.
  - If access is denied or restricted, show the inline error "Flyby can't save to Photos" with **Open Settings** and **Share instead** (`states.md`).
  - Share to Stories / the share sheet needs no Photos permission.
- **Export failure:** inline "Couldn't create the image · Try again". The snapshot times out after 10 s.
- **Ids:** `recap.preview`, `recap.template.*`, `recap.style.*`, `recap.toggle.hideHome`, `recap.toggle.trim`, `recap.toggle.tail`, `recap.save`, `recap.share`, `recap.disclaimer`, `recap.error`. VoiceOver: `accessibility.md` §5.
- Recap text is **excluded from Dynamic Type** (fixed render); the Share controls themselves scale.
