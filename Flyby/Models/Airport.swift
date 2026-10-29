import CoreLocation

/// An airport a pilot can fly from or to. Sprint 1 uses the static list in
/// `MockAirports`; airport search arrives with the backend.
struct Airport: Identifiable, Hashable, Sendable {
    /// ICAO code, e.g. "KSQL".
    let icao: String
    let name: String
    /// Coarse area shown instead of the field when the home airport is hidden
    /// in a share, e.g. "Bay Area" (privacy-sharing.md).
    let region: String
    let latitude: Double
    let longitude: Double

    var id: String { icao }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
