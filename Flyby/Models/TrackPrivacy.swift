import CoreLocation
import Foundation

/// Privacy applied before a flight is drawn on a recap.
///
/// The journal keeps the full track. A share copies it through here first:
/// the home field's name and ICAO come off the card, and the line stops
/// short of that field so the endpoint isn't the airport.
enum TrackPrivacy {
    /// "Track too short to trim; endpoints hidden."
    static let shortTrackNote = "Track too short to trim; endpoints hidden."
    /// Shown in place of the home field's name.
    static let homeFieldNote = "Home field hidden"

    struct Trim: Equatable {
        var points: [TrackPoint]
        /// The path is shorter than the requested trim, so nothing should be drawn.
        var tooShort: Bool
    }

    struct Endpoint: Equatable {
        /// Printed on the card. The region, not the ICAO, when the home field is hidden.
        var label: String
        /// Spoken form. The airport name only when the field is not hidden.
        var spoken: String
        var hidden: Bool
    }

    struct MaskedRoute: Equatable {
        var points: [TrackPoint]
        var departure: Endpoint
        var arrival: Endpoint
        var homeFieldHidden: Bool
        var tooShortToTrim: Bool
        var approximate: Bool
        var unavailable: Bool
    }

    /// Drops `distance` nautical miles from both ends of a validated track.
    /// The cut is interpolated, so the remaining line starts and ends that far from the fields.
    static func trim(_ track: [TrackPoint], distance: Double) -> Trim {
        trim(track, start: distance, end: distance)
    }

    /// Drops `start` nautical miles from the beginning and `end` from the finish.
    static func trim(_ track: [TrackPoint], start: Double, end: Double) -> Trim {
        let points = track.filter(isDrawable)
        let startDistance = max(0, start)
        let endDistance = max(0, end)
        guard points.count >= 2 else { return Trim(points: [], tooShort: true) }
        guard startDistance > 0 || endDistance > 0 else {
            return Trim(points: points, tooShort: false)
        }

        var cumulative: [Double] = []
        cumulative.reserveCapacity(points.count)
        var length = 0.0
        var previous: TrackPoint?
        for point in points {
            if let previous {
                length += Geo.distanceNM(previous.coordinate, point.coordinate)
            }
            cumulative.append(length)
            previous = point
        }
        guard cumulative.count == points.count, let total = cumulative.last else {
            return Trim(points: [], tooShort: true)
        }
        if startDistance + endDistance >= total - 0.000_001 {
            return Trim(points: [], tooShort: true)
        }

        let endAt = total - endDistance
        guard let opening = point(at: startDistance, points: points, cumulative: cumulative),
              let closing = point(at: endAt, points: points, cumulative: cumulative) else {
            return Trim(points: [], tooShort: true)
        }

        var kept = [opening]
        for index in points.indices {
            let along = cumulative[index]
            if along > startDistance + 0.000_1, along < endAt - 0.000_1 {
                kept.append(points[index])
            }
        }
        kept.append(closing)
        kept = droppingDuplicates(kept)
        guard kept.count >= 2 else { return Trim(points: [], tooShort: true) }
        return Trim(points: kept, tooShort: false)
    }

    /// Builds the route a recap is allowed to show.
    ///
    /// `enabled` is the effective "Hide home airport" value for this share.
    /// `trimEnds` trims both ends even when neither field is home.
    /// A hidden home endpoint is always trimmed, so the line doesn't end on the field.
    static func hideHomeAirport(_ flight: Flight,
                                home: Airport,
                                enabled: Bool,
                                trimEnds: Bool,
                                distance: Double) -> MaskedRoute {
        let departure = endpoint(flight.departure, home: home, hide: enabled)
        let arrival = endpoint(flight.arrival, home: home, hide: enabled)
        let homeFieldHidden = departure.hidden || arrival.hidden
        let trimDistance = max(0, distance)
        let startTrim = (trimEnds || departure.hidden) ? trimDistance : 0
        let endTrim = (trimEnds || arrival.hidden) ? trimDistance : 0

        let cleaned = TrackSanitizer.cleaned(flight.track, flightDate: flight.date)
        let source: [TrackPoint]
        let approximate: Bool
        if cleaned.count >= 2 {
            source = cleaned
            approximate = false
        } else if let arc = greatCircle(from: flight.departure, to: flight.arrival) {
            source = arc
            approximate = true
        } else {
            return MaskedRoute(points: [], departure: departure, arrival: arrival,
                               homeFieldHidden: homeFieldHidden, tooShortToTrim: false,
                               approximate: false, unavailable: true)
        }

        let trimmed = trim(source, start: startTrim, end: endTrim)
        if trimmed.tooShort {
            return MaskedRoute(points: [], departure: departure, arrival: arrival,
                               homeFieldHidden: homeFieldHidden, tooShortToTrim: true,
                               approximate: approximate, unavailable: false)
        }
        return MaskedRoute(points: trimmed.points, departure: departure, arrival: arrival,
                           homeFieldHidden: homeFieldHidden, tooShortToTrim: false,
                           approximate: approximate, unavailable: false)
    }

    private static func endpoint(_ airport: Airport, home: Airport, hide: Bool) -> Endpoint {
        let matchesHome = airport.icao.caseInsensitiveCompare(home.icao) == .orderedSame
        guard hide, matchesHome else {
            return Endpoint(label: airport.icao, spoken: airport.name, hidden: false)
        }
        let region = airport.region.trimmingCharacters(in: .whitespacesAndNewlines)
        let spoken = region.isEmpty ? "Home area" : region
        return Endpoint(label: spoken.uppercased(), spoken: spoken, hidden: true)
    }

    /// Samples the great circle. Used when the pilot didn't record a track.
    /// The samples still go through `trim`, so a hidden home field isn't an endpoint.
    private static func greatCircle(from departure: Airport, to arrival: Airport) -> [TrackPoint]? {
        let start = TrackPoint(latitude: departure.latitude, longitude: departure.longitude,
                              altitudeFeet: nil, timestamp: nil)
        let finish = TrackPoint(latitude: arrival.latitude, longitude: arrival.longitude,
                               altitudeFeet: nil, timestamp: nil)
        guard isDrawable(start), isDrawable(finish) else { return nil }
        guard Geo.distanceNM(start.coordinate, finish.coordinate) > 0.05 else { return nil }
        let steps = 32
        return (0..<steps).map { index in
            let fraction = Double(index) / Double(steps - 1)
            let coordinate = Geo.interpolate(start.coordinate, finish.coordinate, fraction: fraction)
            return TrackPoint(latitude: coordinate.latitude, longitude: coordinate.longitude,
                              altitudeFeet: nil, timestamp: nil)
        }
    }

    private static func isDrawable(_ point: TrackPoint) -> Bool {
        let coordinate = point.coordinate
        guard coordinate.latitude.isFinite, coordinate.longitude.isFinite else { return false }
        guard CLLocationCoordinate2DIsValid(coordinate) else { return false }
        if coordinate.latitude == 0, coordinate.longitude == 0 { return false }
        return true
    }

    private static func point(at distance: Double, points: [TrackPoint], cumulative: [Double]) -> TrackPoint? {
        guard let first = points.first, let last = points.last, let total = cumulative.last else { return nil }
        if distance <= 0 { return first }
        if distance >= total { return last }
        guard points.count == cumulative.count else { return nil }
        for index in 1..<points.count {
            let segmentEnd = cumulative[index]
            if distance > segmentEnd { continue }
            let segmentStart = cumulative[index - 1]
            let span = segmentEnd - segmentStart
            let fraction = span > 0.000_000_1 ? (distance - segmentStart) / span : 0
            let left = points[index - 1]
            let right = points[index]
            let coordinate = Geo.interpolate(left.coordinate, right.coordinate, fraction: fraction)
            return TrackPoint(latitude: coordinate.latitude,
                              longitude: coordinate.longitude,
                              altitudeFeet: blend(left.altitudeFeet, right.altitudeFeet, fraction),
                              timestamp: left.timestamp)
        }
        return last
    }

    private static func blend(_ left: Double?, _ right: Double?, _ fraction: Double) -> Double? {
        switch (left, right) {
        case let (left?, right?):
            return left + (right - left) * fraction
        case let (left?, nil):
            return left
        case let (nil, right?):
            return right
        case (nil, nil):
            return nil
        }
    }

    /// Drops a cut that landed on the next kept fix, so the line doesn't double back.
    private static func droppingDuplicates(_ points: [TrackPoint]) -> [TrackPoint] {
        guard let first = points.first else { return [] }
        var kept = [first]
        for point in points.dropFirst() {
            guard let previous = kept.last else { break }
            if Geo.distanceNM(previous.coordinate, point.coordinate) < 0.000_5 { continue }
            kept.append(point)
        }
        return kept
    }
}
