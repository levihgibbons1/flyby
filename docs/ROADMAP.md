# Flyby Product Roadmap (Draft v0.1, Oct 13 2026)

Flyby is a premium social flight journal for pilots. Not a navigation app.
Principles: excellent design, smooth performance, simplicity, private by default.

## Phase 0: Foundations (weeks 1-3)
- Product brief, design language (type, color, motion), core user flows
- Supabase schema: users, profiles, flights, follows, airports, achievements
- Row-level security with flights private by default; per-flight visibility (Private / Followers / Public)
- SwiftUI app shell, auth (Sign in with Apple), CI on GitHub
- Data/privacy policy draft (not published without approval)

## Phase 1: MVP Journal (weeks 4-9)
- Manual flight logging: aircraft, tail number, departure/arrival, times, route, notes, photos
- GPX/KML import for tracks; MapKit route rendering
- Flight detail recap card (map, stats, photos)
- Pilot profile: hours, aircraft flown, airports visited
- Airport database (seeded from public data) with simple airport pages

## Phase 2: Social (weeks 10-15)
- Follow / followers, request-to-follow for private accounts
- Feed of shared recaps, likes ("kudos"), comments
- Shareable recap images (export only on user action)
- Blocking, reporting, moderation basics
- Location privacy: hide home airport / trim track start-end

## Phase 3: Delight and Retention (weeks 16-22)
- Achievements: first solo, new airports, states/countries, night, cross-country
- Airport discovery: visited map, "airports near you", pilot notes
- Yearly stats and recap ("Year in Flight")
- Widgets, Live Activities for an in-progress log (journal only, no nav guidance)

## Phase 4: Premium and Launch (weeks 23-28)
- Flyby Premium (pricing decision needs Levi's approval)
- Performance pass, accessibility, App Store assets
- TestFlight beta, then App Store submission (approval required)

## Later / Ideas
- Apple Watch logging, ForeFlight/Garmin log import, clubs and flight schools, Logbook PDF export

## Open decisions for Levi
1. Track source at launch: manual + GPX import only, or in-app GPS recording?
2. Monetization model and timing
3. Seed airport data source and licensing
