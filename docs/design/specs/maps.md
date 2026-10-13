# Spec: Activity maps (v0.2.1 Skyglass, provisional)

References: `png/03-flight-detail.png`, `png/02-home-feed.png`, `png/01-home-journal.png`, `png/05-flights-logbook.png`, `png/10`–`12` recaps, `png/14-privacy-owner-vs-shared.png`

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
| Flight Detail (393×470) | 5 | 9 | 14 Ø, 2.6 ring | 15 Ø, navy core | dep/arr ICAO, SF Mono Bold 12 + halo |
| Feed card (361×212) | 4.6 | 8.6 | hidden when trimmed | 13 Ø | arrival ICAO + region |
| Journal / big FlightCard (~190 h) | 5 | 9 | owner only | 13 Ø | ICAO |
| Logbook thumbnail (72×72) | 3.2 | 6.4 | 9 Ø (owner's own) | 9 Ø | none |
| Recap map card (360 pt grid, ×3 export) | 5–5.4 | +4.4 | hidden when trimmed | 15 Ø | ICAO + region |

All strokes use `StrokeStyle(lineWidth:, lineCap: .round, lineJoin: .round)`, with a shadow of y 1, blur 3, ink at 28% on the casing.

## MapKit implementation
**Interactive (Flight Detail):**
```swift
Map(position: $camera, interactionModes: [.pan, .zoom]) {
    // MapPolyline has no casing, so draw two polylines: casing, then route
    MapPolyline(coordinates: track)
        .stroke(.white, style: StrokeStyle(lineWidth: 9, lineCap: .round, lineJoin: .round))
    MapPolyline(coordinates: track)
        .stroke(Color.Flyby.route, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
    if showsStart { Annotation("", coordinate: track.first!, anchor: .center) { StartDot() } }
    Annotation("", coordinate: track.last!, anchor: .center) { EndDot() }   // arrival dot pops in after the draw-on
}
.mapStyle(.standard(elevation: .realistic, emphasis: .muted,
                    pointsOfInterest: .excludingAll, showsTraffic: false))
.mapControlVisibility(.hidden)
```
- `StartDot`: a 14 pt white `Circle` with a 2.6 pt `Color.Flyby.route` inner stroke and a shadow. `EndDot`: a 15 pt white circle with an 11 pt `routeEnd` fill. Neither is a `Marker` balloon, because balloons read as navigation destinations.
- Optional altitude gradient: `.stroke(Gradient(colors: altRamp), style: …)` on the top polyline (iOS 17+). The default is solid.
- Camera: `.rect` fit to the (shared or full) geometry with 12% padding; detail offsets 3% upward for the sheet.

**Static (feed cards, thumbnails, recaps):** use `MKMapSnapshotter`, not live `Map`s in lists (MVP AC4.5 scroll performance).
```swift
let config = MKStandardMapConfiguration(elevationStyle: .flat, emphasisStyle: .muted)
config.pointOfInterestFilter = .excludingAll
config.showsTraffic = false
let opts = MKMapSnapshotter.Options()
opts.preferredConfiguration = config
opts.region = region(fitting: sharedTrack, padding: 0.12)  // TRIMMED geometry for non-owners
opts.size = CGSize(width: 361, height: 212)                // thumbnails 72×72, recaps 328×292
opts.traitCollection = UITraitCollection(userInterfaceStyle: scheme)
```
- Draw the casing, route and dots into the snapshot image with `snapshot.point(for:)`, using a `CGPath` with `.round` cap and join.
- Cache by `(flightID, geometryHash, size, scheme)`.
- Recaps render the snapshot inside the template, then `ImageRenderer` exports at 3×.
- Fallback when there's no track: draw a dashed great-circle line (casing 6 pt, route 3 pt, dash 6/5) and label it **"Approximate route"** (AC4.3).

## Privacy (unchanged rules; new rendering)
- Non-owner and shared views use the trimmed geometry from `TrackPrivacy.trim(_:distance:)` (default 1.0 nm).
- If an endpoint is the home field:
  - **no start dot**
  - the route **fades to 0% alpha** over the privacy radius (a radial mask applied to the route layer only; the center is offset per pilot)
  - the endpoint label becomes the region ("BAY AREA")
- The camera fits the trimmed geometry, so it never centers on home.
- No zone ring is drawn in shared views, because a ring would point at the field.
- The owner's view shows the full track, both dots, and a dashed zone ring as a preview.
