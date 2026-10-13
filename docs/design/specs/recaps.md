# Spec: Shareable flight recaps (v0.2.1 Skyglass, provisional)

References: `png/10-recap-story-skyglass-1080x1920.png`, `png/11-recap-story-window-seat-1080x1920.png`, `png/12-recap-square-logbook-1080x1080.png`, `png/08-share-recap.png`

Rendered with `ImageRenderer` at 1080×1920 (Story) and 1080×1080 (Post); the design grid is 360×640 / 360×360 pt at 3×.

| Template | Look | Content |
|---|---|---|
| **A · Skyglass** (Story) | Deep-to-pale sky gradient. A muted activity-map card (r30, white rim) carries the trimmed Flyby Blue route with a white casing. A strong frosted glass stats panel overlaps the card's lower edge | Title, pilot · aircraft, date, "Home field hidden", BAY AREA → KTVL, 4 stats, altitude sparkline |
| **B · Window Seat** (Story) | Muted activity map framed in an aircraft window (vignette and glare), white page. KPAO isn't the home field, so the start dot shows | KPAO → KMRY, names · type · "Tail hidden", 3 stats in a white card |
| **C · Logbook Card** (Post) | Map-forward muted activity map (top 58%) with a glass Flyby chip | BAY AREA → KTVL, type · date, 4 stats, handle |

Rules
1. Privacy is applied before render (`privacy-sharing.md`). In Share, Hide home airport and Trim are **on by default** (MVP AC6.4), and the preview updates live.
2. **Map treatment:** the route always sits on a muted basemap (`MKMapSnapshotter`, `.muted`, `.excludingAll`), never bare on sky or photo. 5–5.4 pt Flyby Blue over a white casing (+2.2 pt per side), round joins, soft shadow. The end dot is navy; there's no start dot when trimmed. See `maps.md`.
3. One hero (the route), 4 facts max, date only (exact times off by default). Tail number off by default.
4. Glass in recaps is always the strong frosted variant (≥ 74% white). Never Clear glass under text. All text ≥ 4.5:1 (ink on frosted panel > 15:1; white on the deep-sky top 5.7:1).
5. Story safe areas: keep key text out of the top 220 px and bottom 260 px at 1080×1920. Post margin 72 px.
6. **Disclaimer:** "Not for navigation" in caption2 (~27 px at 1080 wide), bottom row opposite the handle, on every template; never more prominent than the handle. "Sample data" appears only in mockups.
7. Flyby mark (blue gradient app tile + wordmark) top-left; never over the route.

Share screen: live preview (60%), glass template chips (Skyglass / Window Seat / Square), toggles (Hide home airport, Trim start/end, Show tail number), actions **Save** (glass) and **Share to Stories** (prominent).
