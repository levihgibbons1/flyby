import CoreLocation
import Foundation

/// Great-circle math on a spherical Earth. Good enough for a journal; never
/// used for navigation.
enum Geo {
    static let earthRadiusNM = 3440.065

    /// Great-circle distance in nautical miles.
    static func distanceNM(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> Double {
        let lat1 = a.latitude * .pi / 180, lat2 = b.latitude * .pi / 180
        let dLat = lat2 - lat1
        let dLon = (b.longitude - a.longitude) * .pi / 180
        let h = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
        return 2 * earthRadiusNM * asin(min(1, sqrt(h)))
    }

    /// Total length of a path in nautical miles.
    static func lengthNM(_ coordinates: [CLLocationCoordinate2D]) -> Double {
        zip(coordinates, coordinates.dropFirst()).reduce(0) { $0 + distanceNM($1.0, $1.1) }
    }

    /// Point at `fraction` (0...1) along the great circle from `a` to `b`.
    static func interpolate(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D,
                            fraction: Double) -> CLLocationCoordinate2D {
        let lat1 = a.latitude * .pi / 180, lon1 = a.longitude * .pi / 180
        let lat2 = b.latitude * .pi / 180, lon2 = b.longitude * .pi / 180
        let d = distanceNM(a, b) / earthRadiusNM
        guard d > 1e-9 else { return a }
        let s1 = sin((1 - fraction) * d) / sin(d), s2 = sin(fraction * d) / sin(d)
        let x = s1 * cos(lat1) * cos(lon1) + s2 * cos(lat2) * cos(lon2)
        let y = s1 * cos(lat1) * sin(lon1) + s2 * cos(lat2) * sin(lon2)
        let z = s1 * sin(lat1) + s2 * sin(lat2)
        return CLLocationCoordinate2D(latitude: atan2(z, sqrt(x * x + y * y)) * 180 / .pi,
                                      longitude: atan2(y, x) * 180 / .pi)
    }
}
