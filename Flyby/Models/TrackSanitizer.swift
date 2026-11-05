import CoreLocation
import Foundation

/// Drops points that should not be drawn: invalid coordinates, null island,
/// timestamps far from the flight, consecutive duplicates, and single-point spikes.
enum TrackSanitizer {
    /// About one meter.
    private static let duplicateDistanceNM = 1.0 / 1_852
    private static let maxSpeedKnots = 700.0

    static func cleaned(_ track: [TrackPoint], flightDate: Date) -> [TrackPoint] {
        removeSpikes(removeDuplicates(track.filter { isUsable($0, flightDate: flightDate) }))
    }

    private static func isUsable(_ point: TrackPoint, flightDate: Date) -> Bool {
        let coordinate = point.coordinate
        guard CLLocationCoordinate2DIsValid(coordinate) else { return false }
        if coordinate.latitude == 0, coordinate.longitude == 0 { return false }
        if let timestamp = point.timestamp, abs(timestamp.timeIntervalSince(flightDate)) > 24 * 60 * 60 {
            return false
        }
        return true
    }

    private static func removeDuplicates(_ points: [TrackPoint]) -> [TrackPoint] {
        guard let first = points.first else { return [] }
        var kept = [first]
        for point in points.dropFirst() {
            guard let previous = kept.last else { break }
            if Geo.distanceNM(previous.coordinate, point.coordinate) < duplicateDistanceNM { continue }
            kept.append(point)
        }
        return kept
    }

    /// Drops a single point that teleports out and back. Endpoints stay.
    private static func removeSpikes(_ points: [TrackPoint]) -> [TrackPoint] {
        guard points.count >= 3, let first = points.first else { return points }
        var kept = [first]
        for index in points.indices.dropFirst().dropLast() {
            let point = points[index]
            guard let previous = kept.last else { break }
            let next = points[points.index(after: index)]
            if isSpike(previous, point, next) { continue }
            if Geo.distanceNM(previous.coordinate, point.coordinate) < duplicateDistanceNM { continue }
            kept.append(point)
        }
        if let last = points.last, let previous = kept.last,
           Geo.distanceNM(previous.coordinate, last.coordinate) >= duplicateDistanceNM {
            kept.append(last)
        }
        return kept
    }

    private static func isSpike(_ start: TrackPoint, _ point: TrackPoint, _ end: TrackPoint) -> Bool {
        guard let inbound = speedKnots(start, point), let outbound = speedKnots(point, end) else { return false }
        return inbound > maxSpeedKnots && outbound > maxSpeedKnots
    }

    private static func speedKnots(_ start: TrackPoint, _ end: TrackPoint) -> Double? {
        guard let departed = start.timestamp, let arrived = end.timestamp else { return nil }
        let hours = arrived.timeIntervalSince(departed) / 3600
        let distance = Geo.distanceNM(start.coordinate, end.coordinate)
        if hours <= 0 { return distance > duplicateDistanceNM ? .infinity : 0 }
        return distance / hours
    }
}
