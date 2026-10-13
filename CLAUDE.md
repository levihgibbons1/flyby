# CLAUDE.md — Flyby standing instructions

Read this first, every session.

## What Flyby is
Flyby is a premium iOS social flight journal — "Strava for pilots." Pilots record, log, and share their flights as beautiful maps, stats, and recap cards.

- **NOT for navigation.** Never present Flyby as a navigation, flight-planning, or safety tool. Show a "Not for navigation" disclaimer on **Flight Detail**, the **recap card**, and **About**. Don't let altitude/speed readouts imply instrument-grade accuracy.
- **Private by default.** New flights are Private. **Home airport is hidden by default** (one global setting, overridable per flight / per share).

## Stack
- SwiftUI, MapKit, Supabase (later).
- **Sprint 1 is mock data only.** Data goes through a `FlightStore` protocol with a mock implementation. **No Supabase writes, no network calls to paid services.**
- **Minimum iOS 17.** Liquid Glass (iOS 26) and iOS 18 APIs (TabView `Tab`, zoom transitions) must sit behind `#available` inside the DesignSystem modifiers, with a frosted-material (`.ultraThinMaterial` etc.) fallback on older versions.

## App structure
Five tabs, with these accessibility identifiers (QA tests rely on them):

| Tab | Accessibility id |
|---|---|
| Home | `tab.home` |
| Explore | `tab.explore` |
| Record | `tab.record` |
| Flights | `tab.flights` |
| Profile | `tab.profile` |

## Rules for code
- **Tap targets ≥ 44pt** (including glass buttons).
- **Never force-unwrap tracks** (no `track.first!` / `track.last!`). A route needs **at least 2 valid points**; otherwise show the "Approximate route" placeholder. Validate coordinates and handle antimeridian crossings in map framing and great-circle lines.
- **Design empty, loading, and error states** for every screen (no flights yet, map snapshot failure, failed import, denied permission).
- Support Dynamic Type, Dark Mode, Reduce Motion; add accessibility ids on Flight Detail and the recap. Layout must work on iPhone SE (3rd gen) through 17 Pro Max.

## Workflow
- **One branch per issue:** `feature/<issue#>-slug` (e.g. `feature/1-xcode-scaffold`).
- Open a **PR referencing the issue** (`Closes #N`). Levi reviews and merges.
- **Never push or merge to `main`.**
- **No secrets** in the repo (CI runs gitleaks). **No deploys. No paid services.**
- Read the issue's acceptance criteria (QA comments on each issue and `docs/qa/sprint1-acceptance-criteria.md`) before starting, and meet them before opening the PR.

## Docs map
| Path | What |
|---|---|
| `README.md` | Project intro and rules |
| `docs/ROADMAP.md` | Overall product roadmap |
| `docs/SPRINT-1.md` | Current sprint and its 9 issues |
| `docs/BOTS.md` | The agent team and roles |
| `docs/research/flight-capture.md` | How flights are recorded (phone GPS, imports, manual) |
| `docs/qa/MVP-PLAN.md` | Sprint 1 test plan + full MVP plan |
| `docs/qa/sprint1-acceptance-criteria.md` | Acceptance criteria per issue |
| `docs/qa/design-review-sprint1.md` | QA review of the design specs (fixes required) |
| `docs/design/` (on branch **`design/sprint-1`**) | Design system "Skyglass", specs (incl. `maps.md`), mockups. v0.2.1 now; v0.3 with QA fixes coming |

## Build order (Sprint 1)
1. **#1** Xcode project scaffold and folder structure
2. **#2** Main TabView: Home, Explore, Record, Flights, Profile
3. **#4** Flight model and mock data
4. **#3** Design system components — **only once design v0.3 lands**
5. **#5** Flight Detail screen with MapKit route, stats, photos
6. **#6** Manual flight logging form (mock data, Private by default)
7. **#7** Shareable flight recap card prototype
8. **#9** CI: GitHub Actions build + gitleaks

(#8 is QA's plan/smoke tests, owned by the QA agent.)
