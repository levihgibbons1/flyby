# Spec: Log a Flight (v0.2 Skyglass, provisional)

References: `png/06-log-flight-1.png`, `png/07-log-flight-2-visibility.png`

Presented as a system (glass) sheet from the **Record** tab (`tab.record`). Top bar: glass close button (`xmark`, Cancel) · **Log a Flight** · tinted glass-prominent `checkmark` (Save).

| Section | Fields | Notes |
|---|---|---|
| Import banner | **Import GPX or KML** | Fills route, times, distance, altitude. `.fileImporter` with GPX/KML types |
| Route | From / To (ICAO in SF Mono 20, airport name below), glass swap button; Route (free text) | Airport search sheet |
| Aircraft | Aircraft type (from the user's aircraft); **Tail number** (SF Mono); **Show tail number on shares** (default **off**) | |
| Times (local, zone shown) | Date; Out / Off / On / In; Flight · Block computed | Tap a time to stamp "now" (one-tap capture, inspired by FlightDeck EFB); duration-only entry allowed |
| Notes | Multiline | |
| Photos | Thumbnails + add tile | PHPicker; Photos add-only permission only on Save (MVP P6) |
| **Who can see this flight** | VisibilityPicker: **Private** (preselected, "Default", "Only you") · Followers · Public | "**Private by default.** Only you can see this flight. You can change it anytime." |
| Privacy when shared | Hide home airport (default **on**); Trim start / end stepper (default **1.0 nm**) | Plain-language footer |
| Save | Prominent capsule button + "Flyby is a journal · Not for navigation" | `.sensoryFeedback(.success)` |

Validation: required = date, aircraft, From, To, and either Off/On times or a duration. Inline errors use `danger` text plus an icon.
IDs: `log.save`, `log.cancel`, `log.import`, `visibilityPicker`.
