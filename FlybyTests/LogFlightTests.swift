import Foundation
import Testing
@testable import Flyby

struct LogFlightTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    /// Later than every mock flight, so a logged entry leads the journal.
    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: 6, hour: 18, minute: 4))
            ?? Date(timeIntervalSince1970: 1_799_270_640)
    }

    @Test func logFormDefaultsToPrivate() {
        let first = LogFlightDraft.fresh(now: now, calendar: calendar)
        let later = LogFlightDraft.fresh(now: now.addingTimeInterval(3_600), calendar: calendar)
        #expect(first.visibility == .private)
        #expect(later.visibility == .private)
        #expect(first.visibility == FlightVisibility.default)

        let filled = validDraft()
        #expect(filled.visibility == .private)
        let flight = filled.makeFlight(now: now, calendar: calendar)
        #expect(flight?.visibility == .private)
    }

    @Test func visibilityChangesOnlyWhenChosen() {
        var draft = validDraft()
        draft.aircraftType = "Piper Archer"
        draft.notes = "Edited"
        draft.departureCode = "KPAO"
        #expect(draft.visibility == .private)
        #expect(draft.makeFlight(now: now, calendar: calendar)?.visibility == .private)

        draft.visibility = .public
        #expect(draft.makeFlight(now: now, calendar: calendar)?.visibility == .public)
        #expect(draft.hasEdits(since: validDraft()))
    }

    @Test func cleanFormHasNoEdits() {
        let draft = LogFlightDraft.fresh(now: now, calendar: calendar)
        #expect(draft.hasEdits(since: draft) == false)
    }

    @Test func fourLetterCodesMustBeInTheAirportList() {
        var draft = validDraft()
        #expect(draft.problems().departure == nil)
        #expect(draft.problems().arrival == nil)

        draft.departureCode = "ksql"
        #expect(draft.problems().departure == nil)
        draft.departureCode = " kpao "
        #expect(draft.problems().departure == nil)

        draft.departureCode = ""
        #expect(draft.problems().departure == "Enter the departure airport's 4-letter ICAO code.")
        draft.departureCode = "KSQ"
        #expect(draft.problems().departure == "Departure must be a 4-letter ICAO code, like KSQL.")
        draft.departureCode = "KSQLX"
        #expect(draft.problems().departure == "Departure must be a 4-letter ICAO code, like KSQL.")
        draft.departureCode = "K1QL"
        #expect(draft.problems().departure == "Departure must be a 4-letter ICAO code, like KSQL.")
        draft.departureCode = "XXXX"
        #expect(draft.problems().departure == "XXXX isn't in the airport list.")

        draft.arrivalCode = "NOPE"
        #expect(draft.problems().arrival == "NOPE isn't in the airport list.")
        #expect(draft.makeFlight(now: now, calendar: calendar) == nil)
    }

    @Test func durationMustBePositive() {
        var draft = validDraft()
        draft.durationHoursText = ""
        draft.durationMinutesText = ""
        #expect(draft.problems().duration == "Enter a duration greater than zero.")
        #expect(draft.makeFlight(now: now, calendar: calendar) == nil)

        draft.durationMinutesText = "0"
        #expect(draft.problems().duration == "Enter a duration greater than zero.")

        draft.durationHoursText = "abc"
        #expect(draft.problems().duration == "Hours must be a whole number.")
        draft.durationHoursText = "-1"
        #expect(draft.problems().duration == "Hours must be a whole number.")

        draft.durationHoursText = "1"
        draft.durationMinutesText = "12"
        #expect(draft.problems().duration == nil)
        #expect(draft.resolvedDuration() == 72 * 60)
        #expect(draft.makeFlight(now: now, calendar: calendar)?.flightDuration == 72 * 60)

        draft.durationHoursText = "48"
        draft.durationMinutesText = "1"
        #expect(draft.problems().duration == "Enter a duration of 48 hours or less.")
    }

    @Test func timesCanReplaceDurationWhenArrivalIsLater() {
        var draft = validDraft()
        draft.durationHoursText = ""
        draft.durationMinutesText = ""
        draft.includesTimes = true
        let problems = draft.problems(calendar: calendar)
        #expect(problems.duration == nil)
        #expect(problems.times == nil)
        let flight = draft.makeFlight(now: now, calendar: calendar)
        #expect(flight?.flightDuration == 60 * 60)
        #expect(flight?.blockDuration == 60 * 60)
        #expect(flight?.takeoff != nil)
        #expect(flight?.landing != nil)

        draft.arrivalTime = draft.departureTime
        #expect(draft.problems(calendar: calendar).times == "Arrival must be after departure.")
        #expect(draft.makeFlight(now: now, calendar: calendar) == nil)
    }

    @Test func savedFlightLeadsTheJournalAndUpdatesTotals() {
        let store = FlightStore()
        let before = store.totals()
        var draft = validDraft()
        draft.visibility = .followers
        let flight = draft.makeFlight(now: now, calendar: calendar)
        #expect(flight != nil)
        guard let flight else { return }
        #expect(flight.source == .entered)
        #expect(flight.track.isEmpty)
        #expect(flight.photos.isEmpty)
        #expect(flight.aircraftType == "Cessna 172")
        #expect(flight.tailNumber == "N739PA")
        #expect(flight.departure == MockAirports.ksql)
        #expect(flight.arrival == MockAirports.khaf)
        #expect(flight.route == "Direct")
        #expect(flight.notes == "Bay tour")
        #expect(flight.visibility == .followers)
        #expect(RouteDisplay(flight: flight).kind == .approximate)

        store.add(flight)
        #expect(store.flights.first?.id == flight.id)
        #expect(store.flights.prefix(3).contains { $0.id == flight.id })
        let after = store.totals()
        #expect(after.count == before.count + 1)
        #expect(after.flightTime == before.flightTime + flight.flightDuration)
    }

    @Test func saveHintNamesWhatIsMissing() {
        let hint = LogFlightDraft.fresh(now: now, calendar: calendar).problems().saveHint
        #expect(hint.contains("Enter the aircraft."))
        #expect(hint.contains("departure airport"))
        #expect(hint.contains("arrival airport"))
        #expect(hint.contains("duration greater than zero"))
        #expect(validDraft().problems().saveHint == "Saves this flight to your journal on this device.")
    }

    private func validDraft() -> LogFlightDraft {
        var draft = LogFlightDraft.fresh(now: now, calendar: calendar)
        draft.aircraftType = "Cessna 172"
        draft.tailNumber = "N739PA"
        draft.departureCode = "ksql"
        draft.arrivalCode = " KHAF "
        draft.durationMinutesText = "30"
        draft.route = "Direct"
        draft.notes = "Bay tour"
        return draft
    }
}
