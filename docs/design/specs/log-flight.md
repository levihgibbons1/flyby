# Spec: Log a Flight (v0.3 Skyglass, provisional)

References: `png/06-log-flight-1.png`, `png/07-log-flight-2-visibility.png`, `png/17-state-log-import-error.png`, `png/22-sizes-log-keyboard-se-promax.png`

Presented as a sheet from the **Record** tab (`tab.record`); it's a glass sheet on iOS 26 and the standard sheet on iOS 17/18. Top bar:
- glass close button (`xmark`, Cancel, 40 pt visual / 44 pt hit)
- **Log a Flight**
- prominent `checkmark` (Save). Disabled (`label3` on `fill`) until the form is valid.

| Section | Fields | Notes |
|---|---|---|
| Import banner | **Import GPX or KML** | `.fileImporter` with GPX/KML types (max 20 MB). Fills route, times, distance and altitude. Points are validated (`maps.md`). Failure or partial import shows inline errors (`states.md`) |
| Route | From / To (ICAO in SF Mono 20, airport name below), swap button (44 pt); Route (free text) | Airport search sheet; "No airport matches…" empty state |
| Aircraft | Aircraft type (from the user's aircraft); **Tail number** (SF Mono); **Show tail number on shares** (default **off**) | |
| Times (local, zone shown) | Date; Out / Off / On / In; Flight · Block computed | Tap a time to stamp "now". Duration-only entry is allowed. The row reflows 4-across → 2×2 → a list at AX sizes. **Personal journal times, not a certified logbook** |
| Notes | Multiline | |
| Photos | Thumbnails + add tile | **`PhotosPicker` (PHPicker), no permission prompt.** Logging a flight never requests Photos access. Add-only access is requested **only when saving a recap** (`recaps.md`) |
| **Who can see this flight** | VisibilityPicker: **Private** (preselected, "Default", "Only you") · Followers · Public | "**Private by default.** Only you can see this flight. You can change it anytime." id `log.visibility` |
| Privacy when shared | **Hide home airport**: shows the global default (Profile → Privacy, **On**), caption "Your default (Profile → Privacy): On"; Trim start / end `Stepper` (default from settings, **1.0 nm**) | A change here is a **per-flight override**. It doesn't change the global setting (`privacy-sharing.md`). Sprint 1 may omit this row; the global default then applies |
| Save | Prominent capsule button + disclaimer "Personal journal · Not for navigation" | `.sensoryFeedback(.success)` |

Validation:
- Required: date, aircraft, From and To (or an imported track with ≥ 2 valid points), and either Off/On times or a duration.
- Inline errors use `danger` text plus `exclamationmark.triangle` under the section (e.g. "Add From and To, or import a track, to save.").
- Save's VoiceOver hint names the missing fields.

Keyboard (`png/22`): the focused field scrolls above the keyboard and the 44 pt accessory bar (`.scrollDismissesKeyboard(.interactively)`). Save stays in the nav bar, so it's reachable at any size, including SE.

Ids (F9): `log.save`, `log.cancel`, `log.import`, `log.import.error`, `log.field.dep`, `log.field.arr`, `log.field.date`, `log.field.aircraft`, `log.field.tail`, `log.time.out|off|on|in`, `log.visibility` (renamed from `visibilityPicker`), `log.visibility.private|followers|public`, `log.toggle.hideHome`, `log.trim`, `log.disclaimer`. VoiceOver: `accessibility.md` §5.
