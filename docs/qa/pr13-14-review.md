# QA review: PR #13 (scaffold) and PR #14 (TabView)

Reviewed: Oct 13, 2026, 8:30 PM PT · Reviewer: Flyby QA · Read-only. I made no comments, approvals or merges on GitHub.
Heads reviewed:
- #13 `feature/1-scaffold` @ `ea7a58a`
- #14 `feature/2-tabview` @ `1e3ffe4` (stacked on #13)

Sources: PR bodies, the full diffs, PR comments, `list_check_runs_for_ref` and `list_workflow_runs`, and the screenshots in `/workspace/flyby/review/` (I viewed se-ios17 and pm-ios26 in full; se-ios26 and pm-ios17 were not inspected).
Criteria: `sprint1-acceptance-criteria.md` and the design specs (v0.3.x).

Evidence labels used below:
- **[CR]**: code review finding
- **[CI]**: executed test result seen in CI logs
- **[UV]**: unverified, meaning self-reported by the author or not checked

## Headline: the "passes on iOS 17.5 and 26.2" claim is NOT verified by CI
- **[CI] There are no CI results at all.** `list_check_runs_for_ref` returns `total_count: 0` for both `ea7a58a` and `1e3ffe4`. `list_workflow_runs` returns 0 runs for the repo. No GitHub Actions workflow exists yet (issue #9 is still open).
- **[UV]** The 17.5/26.2 results come only from Claude Code's own PR comments (Oct 13, 7:23 PM PT). Per those comments:
  - #13: unit 1/1 and UI 1/1 on SE and 15 Pro Max on 17.5, and on SE and 17 Pro Max on 26.2
  - #14: unit 1/1 and UI 7/7 with 1 skipped, on all 4 devices
- **[UV]** The PR *bodies* still say "only iOS 26.2 is installed". The iOS 17.5 runtime was installed afterwards with the `xcodes` CLI. That's plausible, but there's no log or `.xcresult` to confirm it.
- **[UV]** The screenshot sheets labeled iOS 17.5 show iOS 17-style chrome (classic tab bar, "Carrier" status bar). That's consistent with the claim, but it isn't test evidence. The author also reports that one screenshot batch earlier ran on the wrong OS because of a duplicate SE simulator name.

## Checklist (both PRs)
| Check | Result | Label |
|---|---|---|
| No force unwraps on tracks | N/A: no track/map code in these PRs. The only `!` is the XCTest `XCUIApplication!` in test classes (acceptable) | [CR] |
| Tracks with < 2 points, dateline crossing | N/A: not in scope (#4/#5). There are no fixtures yet | [CR] |
| Private by default | Only placeholder copy and a hard-coded "Private" pill exist. There's no `Flight` model yet, so it's enforced in #4 | [CR] |
| Hide home airport on by default | N/A: no settings or privacy code yet | [CR] |
| Disclaimer present | Yes: Profile → About "Flyby is a flight journal. Not for navigation." (`profile.disclaimer`), and the Log sheet footer "Flyby is a journal · Not for navigation". Both contain the exact substring. Visible in the screenshots | [CR] + [UV] |
| No secrets / no network code | Diffs contain no keys, URLs, `URLSession` or Supabase. `.gitignore` covers `.env`, `.env.*`, `*.p8`, `*.p12`, `*.xcconfig.local` and `xcuserdata/`. gitleaks "clean" is self-reported | [CR]; gitleaks [UV] |
| iOS 26-only APIs only in DesignSystem behind `#available` | Yes: `tabBarMinimizeBehavior`, `.glass`, `.glassProminent` and `glassEffect` appear only in `Flyby/DesignSystem/LiquidGlass.swift`, each behind `#available(iOS 26.0, *)`. The iOS 17 path is `.regularMaterial` / `.borderedProminent` (matches my N2 recommendation). The TabView uses `.tabItem` + `.tag` (iOS 17-safe). The CI grep rule isn't implemented yet (no CI) | [CR] |
| Deployment target | `IPHONEOS_DEPLOYMENT_TARGET = 17.0` | [CR] |
| Accessibility ids | `tab.home/explore/record/flights/profile` (set on the UIKit tab items), plus `log.cancel`, `log.sheet`, `home.logFlight`, `home.allFlights`, `flights.row.<id>`, `profile.disclaimer`. There's a UI test asserting the order of the ids and labels | [CR]; test run [UV] |
| 44 pt targets | `minHeight: 44` on rows and buttons, and the frosted button style. The toolbar Cancel is a system item (≥ 44) | [CR] |
| Dynamic Type | System text styles. Rows and the profile header switch to a VStack at accessibility sizes. The AX3 screenshots show wrapping without truncating key info | [CR] + screenshots [UV] |
| N2 contrast values | Not attached: **tracked on #3** (design system). Not counted against these PRs | n/a |
| Tests exist | #13: `FlybyTests.appModuleLoads` (trivial) and `FlybyUITests.testAppLaunches`. #14: `TabBarUITests` (4), `AccessibilityAuditUITests` (2), `ScreenshotCaptureUITests` (opt-in, skipped by default) | [CR] |
| Tests ran | Self-reported only. No CI and no attached `.xcresult` | [UV] |
| Crash risks | None found in the reviewed code. `UIImage(systemName:)` / `UIColor(named:)` are guarded. The UIKit tab-bar search is optional-chained. `required init?(coder:)` is unavailable and returns nil (fine) | [CR] |

## Issues (bug template)

### QA-13/14-01: No CI; test results can't be independently verified
- Severity: **High** (process; blocks "verified" status, not the code)
- Affected feature: build/test gate for #13 and #14 (issue #9)
- Steps to reproduce: `list_check_runs_for_ref` on `ea7a58a` and on `1e3ffe4`, then `list_workflow_runs` on the repo.
- Expected: CI runs build and test on iOS 17.x and 26.x (SE and Pro Max), plus the secret scan and the gated-API grep, with logs attached.
- Actual: 0 check runs and 0 workflow runs. The pass claims exist only as PR comments.
- Evidence: [CI] the empty API responses above. [UV] the author's tables in the PR comments.
- Recommended fix: land #9 (a GitHub Actions macOS workflow, destinations pinned with `OS=`, `-parallel-testing-enabled NO` for the iOS 17 runtime, upload `.xcresult`). Until then, have the author attach `xcodebuild` log tails or `.xcresult` summaries for the four runs. Note: Xcode 27 can't download iOS 17 runtimes, so CI needs a runner image or `xcodes` step that provides 17.5. Running the workflow on a GitHub-hosted runner may cost money, which needs Levi's approval.

### QA-14-02: Accessibility audit suppressions are broader than needed
- Severity: **Medium**
- Affected feature: `FlybyUITests/AccessibilityAuditUITests.swift`
- Steps to reproduce: code review of `isContrastBehindTabBar` and `isKnownFalsePositive`.
- Expected: the suppressions match only specific, justified elements.
- Actual:
  - *Every* contrast issue with no element is ignored (`guard let element … else { return true }`).
  - Every `.dynamicType` and `.textClipped` issue with a `nil` label is ignored.
  - Suppressions match on label text ("About", "Recent flights"), which will silently cover future elements with the same text.
  - The audit runs in Light mode at the default size only. The author found a dark-mode contrast bug (2.6:1 "Log a Flight") by screenshot, which the audit missed.
- Evidence: [CR], diff lines 776–814.
- Recommended fix:
  - Scope the suppressions by identifier and OS version, not by label or nil.
  - Run the audit for Dark and AX3 too, using `XCUIDevice.shared.appearance` and a launch argument for the content size.
  - Log ignored issues to the test attachments so the reviewer can see them.

### QA-14-03: Tab ids depend on UIKit introspection and on tab order
- Severity: **Low**
- Affected feature: `App/TabBarAccessibilityIdentifiers.swift`
- Steps to reproduce: code review. The ids are zipped onto `UITabBarController.tabBar.items` by index.
- Expected: stable ids on every supported OS.
- Actual: this works per the author's report on 17.5 and 26.2 [UV]. It would silently break if a future SwiftUI TabView stops using `UITabBarController` or reorders items.
- Evidence: [CR]. `testFiveTabsInOrderWithIdentifiersAndLabels` would catch a regression.
- Recommended fix: keep the test as a required CI check. When the iOS 18+ `Tab` API path is added, check whether `.accessibilityIdentifier` on `Tab` works natively and gate the workaround to iOS 17.

### QA-14-04: VoiceOver sheet modality and the "→" reading
- Severity: **Low**
- Affected feature: Log a Flight sheet; flight rows
- Steps to reproduce:
  1. Open Record and inspect the accessibility tree: the screen behind the sheet is still listed (the author's dump).
  2. Swipe a flight row with VoiceOver on.
- Expected: VoiceOver focus stays in the sheet. Routes read "KPAO to KMRY".
- Actual: modality is unverified on a device. "→" likely reads as "right arrow".
- Evidence: [UV], the author's known-limitations list.
- Recommended fix: an on-device VoiceOver pass (Levi's iPhone, or Claude Code with a device). Add `.accessibilityLabel("KPAO to KMRY …")` in the real FlightRow/FlightCard (#3/#4), as the spec in accessibility.md §5 requires.

### QA-14-05: Wrapper API names differ from platform-fallbacks.md
- Severity: **Low**
- Affected feature: `DesignSystem/LiquidGlass.swift`
- Expected (spec):
  - `flybyGlass(cornerRadius:onMap:)` with a `MapScrim`
  - `flybyGlassButton(prominent:)`
  - `FlybyGlassGroup`
  - the test seam `DesignSystem.forceLegacy` (`#if DEBUG`)
- Actual:
  - `flybyGlass(in:interactive:)`, with no `onMap` or scrim
  - `flybyGlassButtonStyle()` / `flybyGlassProminentButtonStyle()`
  - no group wrapper and no legacy test seam
- Evidence: [CR]
- Recommended fix: acceptable for a placeholder PR. Align the names and add `onMap` + `mapScrim` and the seam in #3, before the map surfaces (#5) use them.

### QA-14-06: Record tab tint is a pre-baked image
- Severity: **Low**
- Affected feature: `RootView.recordIcon`
- Actual: a `static let` UIImage tinted with `UIColor(named: "AccentColor")`, `.alwaysOriginal`. A light/dark switch at runtime may not update the tint. The screenshots show blue in both modes, but those were separate launches.
- Evidence: [CR]; the runtime behavior is [UV]
- Recommended fix: switch the appearance while the app is running and confirm the tint updates. If not, build the image from the current `colorScheme` instead of a static.

### QA-13-07: Swift language mode is 5.0, but MVP-PLAN assumes Swift 6
- Severity: **Low**
- Affected feature: `project.pbxproj` (`SWIFT_VERSION = 5.0`)
- Evidence: [CR]
- Recommended fix: MVP-PLAN allows Swift 5 mode if concurrency warnings get in the way. Record the choice in the README, or move to Swift 6 before the model and store code lands (#4).

## Not verified in this review
- I didn't run any build or test myself; there's no Xcode on the QA box.
- I didn't inspect the se-ios26 and pm-ios17 screenshots.
- Reduce Motion, Reduce Transparency and Increase Contrast weren't exercised (the author also says so).
- An on-device VoiceOver pass hasn't been done.

## Verdicts
- **PR #13 (scaffold): Pass with follow-ups.** The code meets [S1] build structure: iOS 17.0 target, shared scheme, `.gitignore` secret patterns, README, no network code. Follow-ups:
  - QA-13/14-01: CI or attached logs, needed before "tests pass on iOS 17 and 26" can be ticked as verified
  - QA-13-07: Swift language mode
- **PR #14 (TabView): Pass with follow-ups.** The code meets [S1] Tab bar: order, symbols, ids, per-tab NavigationStack, Record opens the sheet with no GPS, and the disclaimer is present. iOS 26 APIs are correctly gated in DesignSystem. Follow-ups:
  - QA-13/14-01 (CI)
  - QA-14-02 (tighten the audit suppressions and add Dark/AX3 audits)
  - QA-14-03 through QA-14-06
  - The N2 contrast values are tracked on #3.
- Neither verdict covers the PM's statement that the QA criteria "pass on iOS 17.5 and 26.2". It is **unverified**: it isn't backed by any CI run.
