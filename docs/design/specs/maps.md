# Spec: Activity maps (v0.3 Skyglass, provisional)

References: `png/03-flight-detail.png`, `png/16-state-flights-map-states.png`, `png/20-state-components.png`, `png/21-sizes-flight-detail-se-promax.png`, `png/02-home-feed.png`, `png/01-home-journal.png`, `png/05-flights-logbook.png`, `png/10`–`12` recaps, `png/14-privacy-owner-vs-shared.png`

## Intent
The look is inspired by Strava's activity maps but isn't a copy of them. The basemap is quiet and the route is loud.
- **Basemap:** muted and low-contrast. It has hillshade and faint contours. Roads, labels and water are de-emphasized, and there are no POIs.
- **Route:** one thick, saturated line with round caps and joins, a **white casing**, and a slight drop shadow.
- **Markers:** start and end dots with white borders.
- **Feed cards** are map-heavy: header → title → 3 stats → edge-to-edge map → Tailwinds row.
- **Logbook rows** use compact 72 pt thumbnails.
- **Flyby, not Strava:** the route is solid Flyby Blue `#0A63DB` (dark `#4DA3FF`), never orange or red. The start dot is white with a blue ring; the end dot is white with a navy `#1E3A8A` core (dark `#A5C8FF`). An altitude gradient (`altLow → altHigh`) is an optional Flight Detail toggle only.
- **Journal, not navigation:** no compass, user-location, pitch or recenter buttons, no ownship, no airways or charts.

## Tokens
| Token | Light | Dark | Note |
|---|---|---|---|
| `route` | `#0A63DB` | `#4DA3FF` | vs land 4.8:1 / 6.4:1, vs water 4.1:1 (non-text ≥ 3:1) |
| `routeCasing` | `#FFFFFF` | `#FFFFFF` | 2 pt per side at detail, 1.6–2 pt on cards |
| `routeEnd` | `#1E3A8A` | `#A5C8FF` | arrival dot core |
| `mapLand / mapWater` | `#EEF0F2 / #D4DFE8` | `#171D27 / #0C141F` | mockup basemap; in-app use MapKit `.muted` |
| `mapRoad / mapRoadCasing` | white / ink 10% | white 10% / black 25% | mockup only |
| `mapHill / mapContour` | ink 3.5% / ink 7% | white 2.5% / white 5% | mockup only |

## Stroke widths and markers (pt)
| Context | Route | Casing (total) | Start dot | End dot | Labels |
|---|---|---|---|---|---|
| Flight Detail (full width × 55% height, 280–520) | 5 | 9 | 14 Ø, 2.6 ring | 15 Ø, navy core | dep/arr ICAO, SF Mono Bold 12 + halo |
| Feed card (width × 0.587) | 4.6 | 8.6 | hidden when trimmed | 13 Ø | arrival ICAO + region |
| Journal / big FlightCard (~190 h) | 5 | 9 | owner only | 13 Ø | ICAO |
| Logbook thumbnail (72×72) | 3.2 | 6.4 | 9 Ø (owner's own) | 9 Ø | none |
| Recap map card (360 pt grid, ×3 export) | 5–5.4 | +4.4 | hidden when trimmed | 15 Ø | ICAO + region |

All strokes use `StrokeStyle(lineWidth:, lineCap: .round, lineJoin: .round)`, with a shadow of y 1, blur 3, ink at 28% on the casing.

## Geometry validation (F2, F3): runs before every map, snapshot, recap and share
Input: raw track points (GPX/KML import or the stored `tracks` row), plus the departure and arrival `Airport?`.

1. **Drop invalid points:** latitude or longitude is NaN or infinite; `|lat| > 90`; `|lon| > 180`; exactly `(0, 0)` ("null island"); and any timestamp outside the flight date ± 24 h (when timestamps exist).
2. **Clean:**
   - remove consecutive duplicates (< 1 m apart)
   - remove single-point spikes (an implied speed > 700 kt between neighbors)
   - then simplify (Douglas-Peucker, 5 m at detail and 25 m for snapshots, keeping first and last)
3. **Decide what to draw** (an exhaustive `enum RouteDisplay`):
   - `valid.count >= 2` → `.track(ValidTrack)`
   - else, both airports known with distinct coordinates → `.approximate(from:to:)`: a dashed great-circle line with the pill **"Approximate route (not flown track)"**
   - else → `.unavailable`: a hatched placeholder, "Route unavailable"
4. **Antimeridian:**
   - Unwrap longitudes so each step is ≤ 180° (`lon += 360` or `-= 360` relative to the previous point).
   - **Split the polyline into segments** wherever the original data crosses ±180°; each segment is drawn as its own `MapPolyline` (casing + route).
   - Compute the fit region on the unwrapped longitudes: `center.lon` is normalized back to −180…180, and `span.lon = maxU − minU` (never > 360).
   - The great-circle fallback goes through `MKGeodesicPolyline` (it handles ±180°), and its points are split the same way.
5. **Privacy trim** (`TrackPrivacy.trim`) runs on the validated track. If < 2 points remain after trimming, use the short-track rule in `privacy-sharing.md`.
6. **Import feedback:** count dropped points. If more than 0 were dropped, show "Imported with warnings · N of M points kept". If 0 were kept, show "Couldn't import" (see `states.md`).

**No force unwraps on geometry.** `first` and `last` are optionals and are bound with `if let`. Snapshot code takes a `ValidTrack`, never `[CLLocationCoordinate2D]`.

**Test fixtures** (`FlybyTests/Fixtures/`):

| Fixture | Points | Expected |
|---|---|---|
| `empty.gpx` | 0 | `.approximate` (airports known) / `.unavailable` |
| `single-point.gpx` | 1 | same as empty |
| `two-points.gpx` | 2 | `.track`, 1 segment |
| `ksql-ktvl-512.gpx` | 512 | `.track`, region ≈ sample |
| `corrupt-points.gpx` | 40 incl. NaN, lat 95, lon −200, (0,0), duplicates, a spike | 33 kept, warning copy |
| `phnl-nzaa.gpx` (Honolulu → Auckland) | 800, crosses 180° | 2 segments; span.lon < 60°; center near −170/190 |
| `panc-uhma.gpx` (Anchorage → Anadyr) | 300, crosses 180° | 2 segments; no globe-wide region |
| `same-airport-no-track` | 0, dep == arr | `.unavailable` (no zero-length great circle) |

## Sizing across devices (F10)
- **Flight Detail map height** = `clamp(containerHeight × 0.55, 280, 520)` pt (`GeometryReader` on the detail container). SE 375×667 → 367 · 6.1–6.3" → ≈ 469 · Pro Max 440×956 → 520. The sheet's medium detent covers the bottom 70 pt of the map.
- **Snapshots** are sized from the real container: width = the cell's measured width, height = width × aspect (feed 212/361, journal card 190/361, recap card 292/328, thumbnail 1:1 at 72 pt), with `scale = displayScale`. Never a hard-coded 361 pt. The cache key includes the size.
- Stroke widths are in points, so they don't change with device width.

## MapKit implementation
**Interactive (Flight Detail):**
```swift
switch routeDisplay(raw: flight.track, dep: flight.dep, arr: flight.arr) {
case .track(let valid):
    Map(position: $camera, interactionModes: [.pan, .zoom]) {
        ForEach(valid.segments.indices, id: \.self) { i in      // pre-split at ±180°
            MapPolyline(coordinates: valid.segments[i])
                .stroke(.white, style: StrokeStyle(lineWidth: 9, lineCap: .round, lineJoin: .round))
            MapPolyline(coordinates: valid.segments[i])
                .stroke(Color.Flyby.route, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
        }
        if showsStart, let start = valid.first { Annotation("Departure", coordinate: start, anchor: .center) { StartDot() } }
        if let end = valid.last { Annotation("Arrival", coordinate: end, anchor: .center) { EndDot() } }
    }
    .mapStyle(.standard(elevation: .realistic, emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: false))
    .annotationTitles(.hidden)
    .mapControlVisibility(.hidden)
    .accessibilityIdentifier("detail.map")
case .approximate(let a, let b):
    ApproximateRouteMap(from: a, to: b)      // MKGeodesicPolyline, dash [6, 5], 3 pt over a 6 pt casing, pill "Approximate route (not flown track)"
case .unavailable:
    MapPlaceholder(.routeUnavailable)        // states.md
}
```
- `StartDot`: a 14 pt white `Circle` with a 2.6 pt `Color.Flyby.route` inner stroke and a shadow. `EndDot`: a 15 pt white circle with an 11 pt `routeEnd` fill. Neither is a `Marker` balloon, because balloons read as navigation destinations. The dots aren't interactive.
- Optional altitude gradient: `.stroke(Gradient(colors: altRamp), style: …)` on the top polyline (iOS 17+). The default is solid.
- Camera: `.rect` fit to the validated (shared or full) region with 12% padding; detail offsets 3% upward for the sheet.
- Glass controls and pills on the map use `flybyGlass(onMap: true)`, which adds the `mapScrim` plate (`accessibility.md` §2).

**Static (feed cards, thumbnails, recaps):** use `MKMapSnapshotter`, not live `Map`s in lists (MVP AC4.5 scroll performance).
```swift
guard case .track(let valid) = display else { return placeholder(for: display) }   // never snapshot < 2 points
let config = MKStandardMapConfiguration(elevationStyle: .flat, emphasisStyle: .muted)
config.pointOfInterestFilter = .excludingAll
config.showsTraffic = false
let opts = MKMapSnapshotter.Options()
opts.preferredConfiguration = config
opts.region = valid.region.padded(0.12)        // TRIMMED + validated geometry for non-owners
opts.size = CGSize(width: width, height: (width * aspect).rounded())   // measured, not fixed
opts.traitCollection = UITraitCollection(userInterfaceStyle: scheme)  // recaps: fixed .light or .dark (night)
```
- Draw the casing, route and dots into the snapshot image with `snapshot.point(for:)`, one `CGPath` per segment, using `.round` cap and join.
- Cache by `(flightID, geometryHash, size, scale, scheme)`.
- **Loading:** shimmer placeholder. **Failure or 10 s timeout:** "Map couldn't load · Retry", with one automatic retry (`states.md`).
- Recaps render the snapshot inside the template, then `ImageRenderer` exports at 3× (`recaps.md`).

## Privacy (unchanged rules; new rendering)
- Non-owner and shared views use the trimmed geometry from `TrackPrivacy.trim(_:distance:)` (default 1.0 nm).
- If an endpoint is the home field:
  - **no start dot**
  - the route **fades to 0% alpha** over the privacy radius (a radial mask applied to the route layer only; the center is offset per pilot)
  - the endpoint label becomes the region ("BAY AREA")
- The camera fits the trimmed geometry, so it never centers on home.
- No zone ring is drawn in shared views, because a ring would point at the field.
- The owner's view shows the full track, both dots, and a dashed zone ring as a preview.
