# Spec: Screen inventory (v0.2.1 Skyglass, provisional)

393×852 pt (iPhone 15/16 Pro), exported at 3× (1179×2556). Light is primary; Dark is shown for Home. **Sample data.**

| # | Screen | File |
|---|---|---|
| 1 | Home: Journal mode (pre-social) | `png/01-home-journal.png` |
| 2 | Home: Social feed (later) | `png/02-home-feed.png` |
| 3 | Flight Detail (owner): map + floating glass sheet | `png/03-flight-detail.png` |
| 4 | Pilot Profile | `png/04-pilot-profile.png` |
| 5 | Flights (logbook list) | `png/05-flights-logbook.png` |
| 6 | Record → Log a Flight 1/2 | `png/06-log-flight-1.png` |
| 7 | Record → Log a Flight 2/2 (visibility, privacy) | `png/07-log-flight-2-visibility.png` |
| 8 | Share Recap | `png/08-share-recap.png` |
| 9 | Home: Journal (Dark variant) | `png/09-home-journal-dark.png` |
| 10–12 | Recaps: Skyglass Story, Window Seat Story, Logbook Card Post | `png/10…`, `png/11…`, `png/12…` |
| 13 | Component sheet (solid content + glass layer) | `png/13-components.png` |
| 14 | Privacy: owner vs shared map | `png/14-privacy-owner-vs-shared.png` |

Not mocked yet: Explore, Achievements gallery, Settings/Privacy, onboarding, empty states.

Sample data: KSQL→KTVL, Cirrus SR22 N482CD, Sep 19 2026, 0:58 flight / 1:12 block, 135 nm, 11,500 ft, avg GS 140 kt. KPAO→KMRY, C172S, Oct 4 2026, 0:44, 64 nm, 5,500 ft. Names, handles and tail numbers are fictional.


All map surfaces (detail, feed and journal cards, logbook thumbnails, recaps, privacy compare) use the activity-map treatment in `maps.md`.
