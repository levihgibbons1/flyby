import CoreLocation
import Foundation

/// One flight in the pilot's journal.
///
/// Privacy: `visibility` defaults to `.private` and `track` is the owner's full,
/// unprocessed recording. Shared views must go through `TrackPrivacy` first.
struct Flight: Identifiable, Hashable, Sendable {
    /// Where the numbers came from (flight-detail.md, data provenance).
    enum Source: Hashable, Sendable {
        /// Imported from a GPX/KML track: values are labeled "recorded".
        case recorded
        /// Typed in by the pilot: values are labeled "entered".
        case entered
    }

    var id: String
    /// The day of the flight (and takeoff time when known).
    var date: Date
    var aircraftType: String
    var tailNumber: String
    var departure: Airport
    var arrival: Airport
    /// Free-text route, e.g. "Direct" or "SQL V25 TVL".
    var route: String
    var takeoff: Date?
    var landing: Date?
    /// Airborne time (takeoff to landing).
    var flightDuration: TimeInterval
    /// Out-to-in time, when entered.
    var blockDuration: TimeInterval?
    var maxAltitudeFeet: Int?
    var notes: String
    var visibility: FlightVisibility
    /// Raw track points; may be empty (the map then shows an approximate route).
    var track: [TrackPoint]
    var source: Source

    init(id: String = UUID().uuidString,
         date: Date,
         aircraftType: String,
         tailNumber: String = "",
         departure: Airport,
         arrival: Airport,
         route: String = "",
         takeoff: Date? = nil,
         landing: Date? = nil,
         flightDuration: TimeInterval,
         blockDuration: TimeInterval? = nil,
         maxAltitudeFeet: Int? = nil,
         notes: String = "",
         visibility: FlightVisibility = .default,
         track: [TrackPoint] = [],
         source: Source = .entered) {
        self.id = id
        self.date = date
        self.aircraftType = aircraftType
        self.tailNumber = tailNumber
        self.departure = departure
        self.arrival = arrival
        self.route = route
        self.takeoff = takeoff
        self.landing = landing
        self.flightDuration = flightDuration
        self.blockDuration = blockDuration
        self.maxAltitudeFeet = maxAltitudeFeet
        self.notes = notes
        self.visibility = visibility
        self.track = track
        self.source = source
    }

    /// "KPAO → KMRY". Visual only; VoiceOver uses `routeSpokenTitle`.
    var routeTitle: String { "\(departure.icao) → \(arrival.icao)" }

    /// "KPAO to KMRY", so VoiceOver doesn't read "right arrow".
    var routeSpokenTitle: String { "\(departure.icao) to \(arrival.icao)" }

    /// Track length when a track exists, otherwise the great-circle distance.
    var distanceNM: Double {
        let coordinates = track.map(\.coordinate)
        if coordinates.count >= 2 {
            return Geo.lengthNM(coordinates)
        }
        return Geo.distanceNM(departure.coordinate, arrival.coordinate)
    }

    /// One sentence for VoiceOver (accessibility.md §5, FlightRow).
    var accessibilitySummary: String {
        let day = date.formatted(.dateTime.weekday(.wide).month(.wide).day())
        let parts = [
            "Flight, \(departure.name) to \(arrival.name)",
            day,
            aircraftType,
            FlightFormat.spokenDuration(flightDuration),
            "\(FlightFormat.distance(distanceNM)) nautical miles",
            "Visibility: \(visibility.title)",
        ]
        return parts.joined(separator: ", ")
    }
}
