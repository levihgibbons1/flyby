# CLAUDE.md — Standing instructions for Claude Code

## What Flyby is
Flyby is a premium iOS social flight journal, "Strava for pilots". Pilots record, log, and share their flights with beautiful maps and recaps.
- **NOT for navigation.** Never build features that imply navigational use.
- **Private by default.** Every flight, profile detail, and share defaults to the most private option.

## Source of truth
- **`main` is the source of truth.** Ignore the `design/sprint-1` branch — it is stale. Use the docs on `main` only.
- Design: `docs/design/DESIGN_SYSTEM.md` is the source of truth for the "Skyglass" white/blue design.

## Stack
- SwiftUI, MapKit, Supabase (later).
- **Sprint 1 uses mock data only. No Supabase in Sprint 1.**
- Minimum iOS **17**. Liquid Glass (iOS 26) must sit behind `#available` checks inside DesignSystem modifiers, with a frosted-material (`.ultraThinMaterial` etc.) fallback. Same for iOS 18-only APIs (e.g. `Tab`-based TabView, zoom transitions): provide iOS 17 fallbacks.

## App structure
Five tabs, with these accessibility identifiers:
| Tab | Accessibility id |
|---|---|
| Home | `tab.home` |
| Explore | `tab.explore` |
| Record | `tab.record` |
| Flights | `tab.flights` |
| Profile | `tab.profile` |

## Design rules (Skyglass, incl. v0.3 fixes from `docs/qa/design-review-sprint1.md`)
- Minimum **44pt** tap targets (including glass buttons).
- **Never force-unwrap tracks** (no `track.first!` / `track.last!`). A route needs **at least 2 points**; otherwise show the "Approximate route" placeholder.
- Handle invalid coordinates (and antimeridian crossings) in map framing and great-circle lines.
- Design and implement **empty, loading, and error states** (no flights yet, map snapshot failure, failed import, denied permission).
- Map height must fit the **iPhone SE**; no fixed 470pt map.
- Add accessibility ids on Flight Detail and the recap; respect Reduce Motion and Dynamic Type.

## Privacy
- **Home airport hidden by default** via one global setting (on by default), overridable per flight or per share.
- New flights default to **Private**.
- A **"Not for navigation"** disclaimer appears on Flight Detail, the recap, and About.

## Workflow
- One branch per GitHub issue: `feature/<issue#>-slug` (e.g. `feature/1-scaffold`).
- Commit often with clear messages.
- Open a PR that references the issue (`Closes #N`).
- **Never push or merge to `main`.** Levi approves merges.
- No secrets in the repo. No deploys. No paid services or new packages/dependencies without asking first.

## Build order (Sprint 1)
Core functionality first, polish later (Levi's decision).
1. #1 Xcode project scaffold — merged (PR #13)
2. #2 TabView with the 5 tabs — merged (PR #14)
3. #9 CI — next
4. #4 Flight model + mock data
5. #5 Flight Detail
6. #6 Flight logging
7. #7 Recap / share
- #3 Design system (full Skyglass) — deferred until after the core flow works.
- #8 is the QA plan (see `docs/qa/`), not a build task.

Notes:
- Use simple system UI for now (standard SwiftUI controls, system colors/materials). Skyglass polish comes with #3 later.
- Non-negotiables even with plain UI: flights private by default; "Hide home airport" on by default; the "Personal journal · Not for navigation" disclaimer; no force unwraps; iOS 17 support.
- Keep the spec's accessibility ids even with plain system UI: `about.disclaimer`, `log.disclaimer`, `settings.hideHome` (on by default), and the `tab.*` ids.
- #9 CI must pin an iOS 17.5 simulator runtime plus iOS 26, run tests on iPhone SE and iPhone 15 Pro Max, and attach test results to PRs. It lands before #4 is reviewed.
- QA follow-up QA-14-02 goes into #3: the accessibility audit test must also cover Dark mode and AX (accessibility) text sizes, with less filtering of issues.
- Tab ids must not rely on UIKit internals.

## Docs map (on `main`)
- `README.md` — project intro
- `CLAUDE.md` — this file
- `docs/ROADMAP.md` — overall plan
- `docs/SPRINT-1.md` — current sprint and tasks
- `docs/BOTS.md` — bot team
- `docs/research/flight-capture.md` — flight recording research
- `docs/qa/MVP-PLAN.md` — QA test plan and MVP plan
- `docs/qa/sprint1-acceptance-criteria.md` — acceptance criteria per issue (incl. N2 contrast check, M3/M5 ids)
- `docs/qa/design-review-sprint1.md` — QA review of design (v0.3 fixes)
- `docs/qa/pr13-14-review.md` — QA review of PRs #13 and #14
- `docs/design/DESIGN_SYSTEM.md` — Skyglass design system v0.3.1 (source of truth)
- `docs/design/proposal.html` — design proposal
- `docs/design/review-pr13-14.md` — Design review of PRs #13 and #14 (M1–M5, L1–L6)
- `docs/design/specs/` — navigation.md, screens.md, flight-detail.md, log-flight.md, recaps.md, privacy-sharing.md, maps.md, motion.md, research.md, platform-fallbacks.md, accessibility.md, states.md
- `docs/design/png/` — 25 mockups (01-home-journal … 25-ios17-fallback-flight-detail-se-15promax)
