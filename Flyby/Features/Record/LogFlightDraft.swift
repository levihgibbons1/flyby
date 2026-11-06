import Foundation

/// What the pilot typed into Log a Flight, and the rules for turning it into
/// a journal entry.
///
/// Visibility starts at `.private` and changes only when `visibility` is set.
/// `makeFlight` builds a local `Flight` for the in-memory store. It does not
/// read the network or write anything off the device.
struct LogFlightDraft: Equatable {
    var date: Date
    var aircraftType: String
    var tailNumber: String
    var departureCode: String
    var arrivalCode: String
    /// Whole hours, as typed. Blank counts as zero.
    var durationHoursText: String
    /// Whole minutes, as typed. Blank counts as zero. May be 60 or more.
    var durationMinutesText: String
    /// When true, same-day departure and arrival times are part of the entry.
    var includesTimes: Bool
    var departureTime: Date
    var arrivalTime: Date
    var route: String
    var notes: String
    var visibility: FlightVisibility

    /// A form that has just been opened. Always Private.
    /// Default times are noon and 1pm so "Add times" starts valid at any hour,
    /// including late evening, without rolling the arrival into the next day.
    static func fresh(now: Date = .now, calendar: Calendar = .current) -> LogFlightDraft {
        let departureTime = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: now) ?? now
        let arrivalTime = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: now) ?? departureTime.addingTimeInterval(60 * 60)
        return LogFlightDraft(
            date: now,
            aircraftType: "",
            tailNumber: "",
            departureCode: "",
            arrivalCode: "",
            durationHoursText: "",
            durationMinutesText: "",
            includesTimes: false,
            departureTime: departureTime,
            arrivalTime: arrivalTime,
            route: "",
            notes: "",
            visibility: .private
        )
    }

    /// True when the pilot has changed something since the form opened.
    /// The clock time on the same day does not count: the date picker opens
    /// on "now" and can drift by a second without the pilot touching it.
    func hasEdits(since baseline: LogFlightDraft, calendar: Calendar = .current) -> Bool {
        aircraftType != baseline.aircraftType
            || tailNumber != baseline.tailNumber
            || departureCode != baseline.departureCode
            || arrivalCode != baseline.arrivalCode
            || durationHoursText != baseline.durationHoursText
            || durationMinutesText != baseline.durationMinutesText
            || includesTimes != baseline.includesTimes
            || route != baseline.route
            || notes != baseline.notes
            || visibility != baseline.visibility
            || !calendar.isDate(date, inSameDayAs: baseline.date)
            || (includesTimes && (departureTime != baseline.departureTime || arrivalTime != baseline.arrivalTime))
    }

    func problems(calendar: Calendar = .current) -> LogFlightProblems {
        var result = LogFlightProblems()
        if aircraftType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            result.aircraft = "Enter the aircraft."
        }
        result.departure = Self.airportError(departureCode, place: "departure")
        result.arrival = Self.airportError(arrivalCode, place: "arrival")

        switch durationEntry() {
        case .invalid(let message):
            result.duration = message
        case .blank:
            if resolvedTimes(calendar: calendar) == nil && !includesTimes {
                result.duration = "Enter a duration greater than zero."
            }
        case .minutes:
            break
        }
        result.times = timeError(calendar: calendar)
        return result
    }

    /// Flight time from the duration fields, or from the times when the
    /// duration was left blank.
    func resolvedDuration(calendar: Calendar = .current) -> TimeInterval? {
        switch durationEntry() {
        case .invalid, .blank:
            guard case .blank = durationEntry(),
                  let times = resolvedTimes(calendar: calendar) else { return nil }
            return times.arrival.timeIntervalSince(times.departure)
        case .minutes(let minutes):
            return TimeInterval(minutes * 60)
        }
    }

    /// A flight the journal can store, or nil while the form is invalid.
    /// Logged flights have no track: Flight Detail draws the approximate route.
    func makeFlight(now: Date = .now, calendar: Calendar = .current) -> Flight? {
        guard problems(calendar: calendar).isValid,
              let departure = MockAirports.airport(icao: departureCode),
              let arrival = MockAirports.airport(icao: arrivalCode),
              let duration = resolvedDuration(calendar: calendar) else { return nil }

        let times = resolvedTimes(calendar: calendar)
        return Flight(
            date: flightDate(times: times, now: now, calendar: calendar),
            aircraftType: trimmed(aircraftType),
            tailNumber: trimmed(tailNumber),
            departure: departure,
            arrival: arrival,
            route: trimmed(route),
            takeoff: times?.departure,
            landing: times?.arrival,
            flightDuration: duration,
            blockDuration: times.map { $0.arrival.timeIntervalSince($0.departure) },
            notes: trimmed(notes),
            visibility: visibility,
            source: .entered
        )
    }

    /// Uppercase, no spaces, capped so the field cannot grow without bound.
    static func cleanedAirportCode(_ raw: String) -> String {
        let collapsed = raw.uppercased().filter { !$0.isWhitespace && !$0.isNewline }
        return String(collapsed.prefix(8))
    }

    /// Digits only, capped so a paste cannot overflow the row.
    static func cleanedDurationText(_ raw: String) -> String {
        String(raw.filter(\.isNumber).prefix(4))
    }

    private static let maxMinutes = 48 * 60

    private enum DurationEntry: Equatable {
        case blank
        case invalid(String)
        case minutes(Int)
    }

    private func durationEntry() -> DurationEntry {
        let hoursText = durationHoursText.trimmingCharacters(in: .whitespacesAndNewlines)
        let minutesText = durationMinutesText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let hours = Self.parseCount(hoursText) else {
            return .invalid("Hours must be a whole number.")
        }
        guard let minutes = Self.parseCount(minutesText) else {
            return .invalid("Minutes must be a whole number.")
        }
        let total = hours * 60 + minutes
        if total == 0 {
            if hoursText.isEmpty && minutesText.isEmpty { return .blank }
            return .invalid("Enter a duration greater than zero.")
        }
        if total > Self.maxMinutes {
            return .invalid("Enter a duration of 48 hours or less.")
        }
        return .minutes(total)
    }

    /// nil when `raw` is not a whole number. Empty is zero.
    private static func parseCount(_ raw: String) -> Int? {
        if raw.isEmpty { return 0 }
        guard raw.allSatisfy(\.isNumber), let value = Int(raw) else { return nil }
        return value
    }

    private static func airportError(_ raw: String, place: String) -> String? {
        let code = normalizedCode(raw)
        if code.isEmpty {
            return "Enter the \(place) airport's 4-letter ICAO code."
        }
        if !isFourLetters(code) {
            let title = place.prefix(1).uppercased() + place.dropFirst()
            return "\(title) must be a 4-letter ICAO code, like KSQL."
        }
        if MockAirports.airport(icao: code) == nil {
            return "\(code) isn't in the airport list."
        }
        return nil
    }

    private static func normalizedCode(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    private static func isFourLetters(_ code: String) -> Bool {
        code.count == 4 && code.allSatisfy { $0.isASCII && $0.isLetter }
    }

    private func timeError(calendar: Calendar) -> String? {
        guard includesTimes else { return nil }
        let departure = combining(time: departureTime, on: date, calendar: calendar)
        let arrival = combining(time: arrivalTime, on: date, calendar: calendar)
        if arrival > departure { return nil }
        return "Arrival must be after departure."
    }

    private func resolvedTimes(calendar: Calendar) -> (departure: Date, arrival: Date)? {
        guard includesTimes, timeError(calendar: calendar) == nil else { return nil }
        return (
            combining(time: departureTime, on: date, calendar: calendar),
            combining(time: arrivalTime, on: date, calendar: calendar)
        )
    }

    /// A flight logged today sorts as "just now", so it leads Home and Flights.
    /// An earlier day sorts at the end of that day and leads that day's group.
    private func flightDate(times: (departure: Date, arrival: Date)?, now: Date, calendar: Calendar) -> Date {
        if let times { return times.departure }
        if calendar.isDate(date, inSameDayAs: now) { return now }
        let start = calendar.startOfDay(for: date)
        return calendar.date(byAdding: DateComponents(day: 1, second: -1), to: start) ?? date
    }

    private func combining(time: Date, on day: Date, calendar: Calendar) -> Date {
        var parts = calendar.dateComponents([.year, .month, .day], from: day)
        let clock = calendar.dateComponents([.hour, .minute], from: time)
        parts.hour = clock.hour
        parts.minute = clock.minute
        return calendar.date(from: parts) ?? day
    }

    private func trimmed(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Why a draft cannot be saved yet. Empty means that part is fine.
struct LogFlightProblems: Equatable {
    var aircraft: String?
    var departure: String?
    var arrival: String?
    var duration: String?
    var times: String?

    var isValid: Bool {
        aircraft == nil && departure == nil && arrival == nil && duration == nil && times == nil
    }

    /// Spoken on the dimmed Save button. Names the same problems as the inline text.
    var saveHint: String {
        if isValid { return "Saves this flight to your journal on this device." }
        return [aircraft, departure, arrival, duration, times]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}
