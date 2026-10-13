# Spec: Screen inventory (v0.3.1 Skyglass, provisional)

The primary frame is 393×852 pt (iPhone 15/16/17 Pro), exported at 3× (1179×2556). **Also specified:** iPhone SE 375×667 (home button, 20 pt status bar) and Pro Max 440×956. Light is primary; Dark is shown for Home. **Sample data.**

| # | Screen | File |
|---|---|---|
| 1 | Home: Journal mode (pre-social) | `png/01-home-journal.png` |
| 2 | Home: Social feed (later) | `png/02-home-feed.png` |
| 3 | Flight Detail (owner): map + floating glass sheet | `png/03-flight-detail.png` |
| 4 | Pilot Profile | `png/04-pilot-profile.png` |
| 5 | Flights (logbook list) | `png/05-flights-logbook.png` |
| 6 | Record → Log a Flight 1/2 | `png/06-log-flight-1.png` |
| 7 | Record → Log a Flight 2/2 (visibility; read-only home-airport note) | `png/07-log-flight-2-visibility.png` |
| 8 | Share Recap | `png/08-share-recap.png` |
| 9 | Home: Journal (Dark variant) | `png/09-home-journal-dark.png` |
| 10–12 | Recaps: Skyglass Story, Window Seat Story, Logbook Card Post | `png/10…`, `png/11…`, `png/12…` |
| 13 | Component sheet (solid content + glass layer) | `png/13-components.png` |
| 14 | Privacy: owner vs shared map | `png/14-privacy-owner-vs-shared.png` |
| 15 | State: Home, new pilot (no flights) | `png/15-state-home-empty.png` |
| 16 | State: Flights map states (loading, failed, approximate, unavailable) | `png/16-state-flights-map-states.png` |
| 17 | State: Log import failed/partial, required fields, airport not found | `png/17-state-log-import-error.png` |
| 18 | State: Share, Photos denied + export failed | `png/18-state-share-photos-denied.png` |
| 19 | Profile → Settings: Privacy (global Hide home airport) + About disclaimer | `png/19-settings-privacy-about.png` |
| 20 | State components (EmptyStateView and map placeholders) | `png/20-state-components.png` |
| 21 | Sizes: Flight Detail, SE + Pro Max (44 pt hit areas shown on SE) | `png/21-sizes-flight-detail-se-promax.png` |
| 22 | Sizes: Log a Flight with the keyboard up, SE + Pro Max | `png/22-sizes-log-keyboard-se-promax.png` |
| 23 | Sizes: Share preview, SE + Pro Max | `png/23-sizes-share-se-promax.png` |
| 24 | Recap: Logbook Card, Night (fixed dark export; Night is Logbook Card only) | `png/24-recap-square-night-1080x1080.png` |
| 25 | iOS 17 fallback: Flight Detail on iPhone SE + iPhone 15 Pro Max (thickMaterial + scrim, bordered buttons) | `png/25-ios17-fallback-flight-detail-se-15promax.png` |

Profile (`png/04`): the gear icon (44 pt hit area) opens **Settings** (`png/19`):
- **Privacy:** default visibility Private; **Hide home airport, global, On by default**; home airport (only you); default trim 1.0 nm.
- **About:** the disclaimer block containing the exact substring "Not for navigation", plus "not a certified logbook" and "recorded altitudes, speeds and routes are approximate".

The "Not for navigation" disclaimer appears on Flight Detail, the Log save footer, every recap template and style, the Share preview (inside the recap), and Profile → Settings → About.

Layout rules for other sizes (F10):
- Flight Detail map = `clamp(H × 0.55, 280, 520)`.
- Snapshot sizes are measured from the container.
- The Share preview scales 40% (SE) / 60% / 66% (Pro Max).
- Keyboard-aware Log form.
- Everything is laid out at Dynamic Type AX3 (`accessibility.md` §4).

Not mocked yet: Explore, Achievements gallery, onboarding.

Sample data:
- KSQL→KTVL, Cirrus SR22 N482CD, Sep 19 2026, 0:58 flight / 1:12 block, 135 nm, 11,500 ft, avg GS 140 kt.
- KPAO→KMRY, C172S, Oct 4 2026, 0:44, 64 nm, 5,500 ft.
- Names, handles, file names and tail numbers are fictional.

All map surfaces (detail, feed and journal cards, logbook thumbnails, recaps, privacy compare) use the activity-map treatment and geometry validation in `maps.md`.
