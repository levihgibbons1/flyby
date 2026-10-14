# Screenshots for PR #14 (issue #2, Main TabView)

Review artifacts only. This branch is never merged.

- `sheets/`: one contact sheet per device/OS (rows: Light, Dark, Large text AX3; columns: Home, Home bottom, Explore, Flights, Profile, Record → Log a Flight)
- `screens/`: the individual 72 screenshots, named `<device>-<os>-<mode>-<screen>.png`
- `accessibility/`: full XCUITest accessibility trees per mode, plus `*-voiceover-labels.md`, the labels VoiceOver exposes on each screen

Captured with `FlybyUITests/ScreenshotCaptureUITests` (`TEST_RUNNER_FLYBY_SCREENSHOT_DIR=…`), with appearance and text size set via `xcrun simctl ui`. Status bar overridden to 9:41.
