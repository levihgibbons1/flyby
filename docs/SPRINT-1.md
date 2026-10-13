# Flyby — Sprint 1

**Goal:** a native SwiftUI prototype that runs in Xcode, using mock data only (no Supabase writes).
**Rules:** a social flight journal, not a navigation app. Flight data is private by default. Every AI tool works in a feature branch and opens a PR. Nothing gets pushed to main.

| # | Issue | Labels |
|---|-------|--------|
| [#1](https://github.com/levihgibbons1/flyby/issues/1) | Xcode project scaffold and folder structure | claude-code |
| [#2](https://github.com/levihgibbons1/flyby/issues/2) | Main TabView: Home, Explore, Record, Flights, Profile | claude-code |
| [#3](https://github.com/levihgibbons1/flyby/issues/3) | Design system components (blocked on design/sprint-1) | claude-code, design |
| [#4](https://github.com/levihgibbons1/flyby/issues/4) | Flight model and mock data | codex |
| [#5](https://github.com/levihgibbons1/flyby/issues/5) | Flight Detail screen with MapKit route, stats, photos | claude-code |
| [#6](https://github.com/levihgibbons1/flyby/issues/6) | Manual flight logging form (Private by default) | codex, privacy |
| [#7](https://github.com/levihgibbons1/flyby/issues/7) | Shareable flight recap card prototype | codex, privacy |
| [#8](https://github.com/levihgibbons1/flyby/issues/8) | Sprint 1 QA plan and smoke tests (from qa/sprint-1) | qa |
| [#9](https://github.com/levihgibbons1/flyby/issues/9) | CI: GitHub Actions build + gitleaks | codex, qa |

Suggested order: #1, then #4 and #2, then #3 (once the design spec lands), then #5, #6, #7, and #9. #8 runs in parallel.

## QA plan
QA's test plan and acceptance criteria will be on branch [`qa/sprint-1`](https://github.com/levihgibbons1/flyby/tree/qa/sprint-1). QA acceptance criteria (v0.1) are posted as comments on each issue.
