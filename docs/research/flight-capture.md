# Flyby — How to Capture a Pilot's Flight Track
_Research by PM, Oct 13, 2026. Draft for Levi's review. Sources are listed at the bottom; [n] refers to them._

## TL;DR
At launch, record with the iPhone's own GPS (tap Record → Stop), and let pilots **import files** they already have (ForeFlight KML, Garmin Pilot GPX, G1000 CSV, generic GPX/KML). Add direct connection to external receivers (Stratux/Sentry/GDL 50 via GDL 90 over Wi-Fi) in v1.1. **Don't build on public tracking lookups** at launch: commercial licensing is costly or restricted, small planes have coverage gaps at low altitude, and it clashes with our private-by-default promise.

## 1. iPhone GPS in flight
- **Works in airplane mode, no cell signal needed.** GPS only receives satellite signals; airplane mode turns off transmitters, not GPS reception [1][2]. ForeFlight says a cellular data plan isn't needed for a GPS fix. Wi-Fi-only iPads have **no GPS chip** and need an external receiver [3].
- **Accuracy:** typically ~5–15 m with a clear sky view. GPS altitude is geometric, not barometric, so it can differ from the altimeter by tens of meters [2]. Good enough for a journal map and recap, not for navigation (we already show a "Not for navigation" note).
- **Cockpit issues:** the airframe blocks signal (Faraday-cage effect) when there's no sky view [4]. Heated windshields and phone cases can hurt reception. ForeFlight's advice: clear view of the sky, get a fix before takeoff, auto date/time on [3]. Consumer GPS cuts out above ~60,000 ft / 1,000 kt (irrelevant for GA) [2].
- **Background recording:** on iOS 17+, turn on Background Modes → Location updates, keep a `CLBackgroundActivitySession` alive, and loop over `CLLocationUpdate.liveUpdates()`. This works with "While Using" permission, so we don't need "Always" [5][6]. After iOS relaunches the app in the background, recreate the session [5].
- **Battery:** continuous GPS drains battery. Mitigations: an "airborne" activity type with sensible distance filtering, a reminder to plug in for long flights, and saving points to disk regularly so a crash doesn't lose the flight. We need to measure the real drain on device in Sprint 2 (no reliable published number found).
- **Gaps:** if the fix drops mid-flight, show the gap honestly (dashed line) rather than inventing a path.

## 2. External receivers (Stratux, Sentry, Garmin GDL, Dual XGPS)
- Most portable ADS-B/GPS boxes (Stratux, Sentry, GDL 50/51/52) give better GPS, some AHRS (attitude) data, and ADS-B traffic [7][8][9].
- **How apps connect:** the iPhone joins the device's **Wi-Fi**, and the device streams **GDL 90** messages over UDP to port 4000. Apps announce themselves on UDP 63093 (ForeFlight's GDL 90 extension spec). Stratux documents the same flow [10][11]. On iOS this also needs **Local Network** permission [8].
- Some devices are closed or proprietary. CloudAhoy can't read Stratus directly and imports via ForeFlight instead [12]. Garmin GDL usage outside Garmin/ForeFlight is limited (not verified for third parties).
- Bluetooth GPS units (Dual XGPS, Bad Elf) are supported by CloudAhoy [13]. On iOS they usually feed location through Apple's accessory program (MFi) or the vendor's SDK. Needs vendor checking before we commit.
- **Verdict:** a great "Pro" feature for v1.1 (GDL 90 over Wi-Fi covers Stratux, Sentry and many others with one code path).

## 3. Importing from other apps and devices
| Source | Format | How |
|---|---|---|
| ForeFlight track logs | KML (mobile & web), GPX/CSV (web only) | Share → "Open KML in…" [14] |
| Sentry Plus | Records its own track logs (1 Hz, up to 16 stored), imported into ForeFlight [9] | via ForeFlight export |
| Garmin Pilot | GPX | Logbook → Entry → Share → Track (GPX) [15] |
| Garmin G1000/G3000 | CSV on the SD card (`data_log` folder) | Copy file → import [16] |
| G3X/G5/Avidyne/Dynon etc. | Various CSV | CloudAhoy supports them [13] |
| Apple Watch | HealthKit workout routes (`HKWorkoutRoute`) [17] | Only if the pilot logged a "workout". Niche, later |

- MyFlightbook takes KML, GPX, IGC, NMEA and CSV, and **auto-detects takeoffs, landings and airports** from the track [18][19]. Worth copying for our auto-fill.
- Imports are **free, private and offline-friendly**, and they bring in high-quality data (avionics CSV is the "best quality" tier per CloudAhoy [13]).

## 4. Public tracking lookup by tail number
- **OpenSky:** free only for non-profit research and education. **Any commercial or "operational live product" use needs a written license**, priced by negotiation. Cloud servers may be blocked [20][21][22].
- **ADS-B Exchange:** the RapidAPI plan is $10/mo but **non-commercial only**. Commercial use needs an enterprise license with quote-based pricing [23][24].
- **FlightAware AeroAPI:** pay per query (e.g. track ≈ $0.012 per result set). The Personal tier has no history. **Standard starts at $100/mo minimum** (unlocks history), Premium $1,000/mo [25].
- **Coverage gaps:** ADS-B ground reception needs line of sight. Low-altitude GA flights, mountains and remote areas (e.g. ~40% of Alaska at GA altitudes) have gaps [26][27]. Planes without ADS-B Out don't show up at all.
- **Privacy:** the FAA's **LADD** program hides aircraft from FAA-fed tracking feeds, and **PIA** gives aircraft a temporary address not linked to the registry [28][29]. Hobby trackers can still see raw broadcasts. Pulling a pilot's flights by tail number means pulling data they didn't create, possibly against their wishes. Bad fit for "private by default". If we ever do it, it should be opt-in, verified ownership of the tail number, and respect LADD/PIA.

## 5. Competitors
- **CloudAhoy:** "Easiest: our iOS app (phone GPS, optional Bluetooth GPS). Better: ForeFlight + Stratus. Best: import from your EFIS." Huge import list (ForeFlight, FlyQ, Garmin Pilot, SkyDemon, Stratux, Sentry, G1000…) [13][30].
- **ForeFlight:** records track logs with automatic start/stop, in the background, from the device GPS or a connected receiver (Sentry/Stratus). Exports KML/GPX/CSV [14][9].
- **MyFlightbook:** logbook first. Imports telemetry files and auto-fills from them [18][19].
- **FlyQ EFB:** an EFB whose flights can be imported into CloudAhoy [30].
- **Strava model:** phone records, plus imports from watches and devices. Same pattern: record natively, import everything else.
None of them rely on public ADS-B lookups as the main capture method.

## Comparison
| Method | Cost to us | Works with no signal | Accuracy | Effort for the pilot | Privacy | Build effort |
|---|---|---|---|---|---|---|
| iPhone GPS recording | Free | Yes | Good (5–15 m) | Tap Record/Stop | Excellent | Medium |
| File import (KML/GPX/CSV) | Free | Yes (after the flight) | Good–Best | A few taps | Excellent | Low–Med |
| External receiver (GDL 90) | Free | Yes | Better, + attitude | Pair once | Excellent | Medium |
| Apple Watch route | Free | Yes | OK | Start a workout | Good | Medium |
| Tail-number lookup | $100+/mo or license | n/a | Varies, gaps at low altitude | None | Poor | Med + legal |

## Recommendation
**Launch (MVP):**
1. Phone GPS recording (iOS 17+ live updates, background session, saved to disk often, gaps shown honestly).
2. File import: GPX + KML (covers ForeFlight, Garmin Pilot and most others) through the iOS share sheet ("Open in Flyby").
3. Manual logging (already in Sprint 1) as a fallback.
4. Auto-detect takeoff and landing plus nearest airports from the track (MyFlightbook-style), with the home airport hidden on shared maps.

**Later:**
- v1.1: G1000/G3X CSV import; GDL 90 Wi-Fi receivers (Stratux, Sentry, etc.); ForeFlight CSV.
- v1.2+: Apple Watch; Bluetooth GPS vendors (after SDK check); automatic start/stop detection.
- Maybe: an opt-in tail-number "fill the gap" lookup via FlightAware, only for verified owners, respecting LADD/PIA, and only once revenue justifies $100+/mo.

## Sources
1. Apple Community, GPS in airplane mode — https://discussions.apple.com/thread/8048257
2. SkyLocation, Track your location on a plane — https://www.skylocation.app/blog/track-location-on-plane
3. ForeFlight Support, Maximizing GPS accuracy — https://support.foreflight.com/hc/en-us/articles/16195334269335
4. Apple StackExchange, iPhone GPS at cruise — https://apple.stackexchange.com/questions/225450
5. Apple, Handling location updates in the background — https://developer.apple.com/documentation/corelocation/handling-location-updates-in-the-background
6. Apple WWDC23, Discover streamlined location updates — https://developer.apple.com/videos/play/wwdc2023/10180/
7. ForeFlight, Support for Garmin GDL 50/51/52 — https://foreflight.com/enhancements/support-for-garmin-gdl-50-51-52
8. ForeFlight Support, Connecting Sentry — https://support.foreflight.com/hc/en-us/articles/24683515609239
9. ForeFlight Sentry guide — https://www.foreflight.com/sentry-guide/
10. ForeFlight GDL 90 Extended Spec — https://www.foreflight.com/connect/spec/
11. Stratux app-vendor integration notes — https://github.com/cyoung/stratux/blob/master/notes/app-vendor-integration.md
12. ForeFlight Support, Stratus & CloudAhoy — https://support.foreflight.com/hc/en-us/articles/13650756678551
13. CloudAhoy, Log or import a flight — https://help.cloudahoy.com/log-or-import-flight/
14. ForeFlight Support, Exporting track logs — https://support.foreflight.com/hc/en-us/articles/27632618331927
15. Pilot Life Help, Sharing from Garmin Pilot — https://help.pilotlife.com/en/articles/9265170-how-do-i-share-my-flight-from-garmin-pilot
16. ForeFlight Support, G1000/3000 import into CloudAhoy — https://support.foreflight.com/hc/en-us/articles/14607296021015
17. Apple, HKWorkoutRoute — https://developer.apple.com/documentation/healthkit/hkworkoutroute
18. MyFlightbook, Telemetry data description — https://myflightbook.com/logbook/mvc/pub/FlightDataKey
19. MyFlightbook blog, Auto-fill — http://myflightbookblog.blogspot.com/2022/01/auto-fill-functionality.html
20. OpenSky Terms of Use — https://opensky-network.org/about/terms-of-use
21. OpenSky FAQ — https://opensky-network.org/about/faq
22. OpenSky REST API docs — https://openskynetwork.github.io/opensky-api/rest.html
23. ADS-B Exchange on RapidAPI (pricing) — https://rapidapi.com/adsbx/api/adsbexchange-com1/pricing
24. ADS-B Exchange Help, non-commercial company use — https://adsbx.zendesk.com/hc/en-us/articles/37363886073613
25. FlightAware AeroAPI — https://www.flightaware.com/commercial/aeroapi
26. FAA ADS-B FAQ — https://www.faa.gov/air_traffic/technology/adsb/faq
27. AOPA, GA seeks ADS-B coverage in Alaska — https://www.aopa.org/news-and-media/all-news/2019/october/08/ga-seeks-adsb-coverage-in-alaska
28. FAA ADS-B Privacy (PIA) — https://www.faa.gov/air_traffic/technology/equipadsb/privacy
29. FAA LADD — https://www.faa.gov/pilots/ladd
30. CloudAhoy home page — https://www.cloudahoy.com/
