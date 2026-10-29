import CoreLocation
import Foundation

/// Generates believable, deterministic flight tracks for mock flights: a gently
/// curved great-circle path that starts and ends exactly on the airports,
/// with a climb, cruise and descent profile and evenly spaced timestamps.
enum MockTrack {
    static func generate(from departure: Airport,
                         to arrival: Airport,
                         points count: Int,
                         cruiseFeet: Double,
                         takeoff: Date,
                         duration: TimeInterval,
                         bow: Double = 0.06) -> [TrackPoint] {
        guard count >= 2 else { return [] }
        let start = departure.coordinate, end = arrival.coordinate
        // Unit vector perpendicular to the route, in degrees.
        let dLat = end.latitude - start.latitude, dLon = end.longitude - start.longitude
        let length = max(sqrt(dLat * dLat + dLon * dLon), 1e-9)
        let perpendicular = (lat: -dLon / length, lon: dLat / length)
        let span = length

        return (0..<count).map { index in
            let f = Double(index) / Double(count - 1)
            let base = Geo.interpolate(start, end, fraction: f)
            // Zero at both ends, so the track starts and ends on the field.
            let offset = span * (bow * sin(.pi * f) + 0.008 * sin(.pi * f) * sin(9 * .pi * f))
            let climb = smoothstep(min(f / 0.2, 1))
            let descent = smoothstep(min((1 - f) / 0.25, 1))
            return TrackPoint(latitude: base.latitude + perpendicular.lat * offset,
                              longitude: base.longitude + perpendicular.lon * offset,
                              altitudeFeet: (cruiseFeet * min(climb, descent)).rounded(),
                              timestamp: takeoff.addingTimeInterval(duration * f))
        }
    }

    private static func smoothstep(_ x: Double) -> Double { x * x * (3 - 2 * x) }
}
