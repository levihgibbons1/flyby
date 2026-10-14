import CoreLocation
import Foundation

/// One recorded position from an imported GPX/KML track. Points are raw input:
/// they may be invalid until `TrackGeometry` validates them.
struct TrackPoint: Hashable, Sendable {
    var latitude: Double
    var longitude: Double
    var altitudeFeet: Double?
    var timestamp: Date?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
