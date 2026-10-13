# Flyby

Flyby is a premium iOS social flight journal, a "Strava for pilots." Pilots can log flights, relive them as beautiful MapKit recaps, share flight recaps, follow other pilots, discover airports, and build an aviation profile. **Flyby is a journal, not a navigation app. Don't use it for flight planning or navigation.** Flight data is **private by default**, and nothing is shared unless the pilot chooses to share it.

## Stack
- **SwiftUI** for the native iOS app (iOS 17+)
- **MapKit** for route maps and recaps
- **Supabase** for the backend (planned; Sprint 1 uses mock data only)

## Build and run
**Requirements:** Xcode 26 or later (developed on Xcode 27.0), iOS 17.0+ deployment target. No third-party dependencies, no signing team needed for the Simulator, no secrets.

1. Clone the repo and open `Flyby.xcodeproj`.
2. Pick the `Flyby` scheme and an iPhone Simulator.
3. ⌘R to run, ⌘U to run the tests.

From the command line:
```bash
# Build
xcodebuild -project Flyby.xcodeproj -scheme Flyby \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build CODE_SIGNING_ALLOWED=NO

# Unit tests (FlybyTests, Swift Testing) + UI tests (FlybyUITests, XCTest)
xcodebuild -project Flyby.xcodeproj -scheme Flyby \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' test CODE_SIGNING_ALLOWED=NO
```
QA's smallest test device is iPhone SE (3rd generation). If your Xcode has no SE simulator, create one in Xcode → Window → Devices and Simulators, or use the iPhone 16e.

## Project structure
```
Flyby/
  App/            App entry point and root view
  Features/       One folder per screen/tab (Home, Explore, Record, Flights, Profile, …)
  DesignSystem/   Skyglass tokens and reusable components (docs/design/DESIGN_SYSTEM.md)
  Models/         Flight, Airport, Aircraft, PilotProfile
  MockData/       Sample flights and airports (Sprint 1 is mock data only)
FlybyTests/       Unit tests
FlybyUITests/     UI tests
```
The project uses Xcode folder-synchronized groups: add files to these folders on disk and Xcode picks them up, with no `project.pbxproj` edits needed. (Empty folders keep a `.gitkeep`, which is excluded from the app target.)

## Workflow rules
- All work happens in feature branches (`feature/…`, `design/…`, `qa/…`, `docs/…`) and is merged via pull request.
- **No direct pushes to `main`.** Merges to main need Levi's approval.
- No secrets or keys in the repo. No deploys without approval.
- AI tools (Claude Code, Codex) follow the same rules: one branch per issue and a PR for review.

## Sprint 1 issues
- [#1 Xcode project scaffold](https://github.com/levihgibbons1/flyby/issues/1)
- [#2 Main TabView](https://github.com/levihgibbons1/flyby/issues/2)
- [#3 Design system components](https://github.com/levihgibbons1/flyby/issues/3)
- [#4 Flight model and mock data](https://github.com/levihgibbons1/flyby/issues/4)
- [#5 Flight Detail with MapKit](https://github.com/levihgibbons1/flyby/issues/5)
- [#6 Manual flight logging](https://github.com/levihgibbons1/flyby/issues/6)
- [#7 Shareable recap card](https://github.com/levihgibbons1/flyby/issues/7)
- [#8 Sprint 1 QA plan](https://github.com/levihgibbons1/flyby/issues/8)
- [#9 CI: build + gitleaks](https://github.com/levihgibbons1/flyby/issues/9)
