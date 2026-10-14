import Observation

/// The pilot's profile and privacy settings (in memory for Sprint 1).
///
/// Privacy defaults are the most private option (privacy-sharing.md):
/// the home airport is hidden in shares and new flights are Private.
@Observable
final class ProfileStore {
    var pilotName: String
    /// Precise home field. Only the owner ever sees it; shares show its region.
    var homeAirport: Airport
    /// Global "Hide home airport" setting. On by default; a share can override
    /// it for that share only, without changing this value.
    var hideHomeAirport: Bool
    /// Distance trimmed from each end of a shared track.
    var defaultTrimNM: Double
    /// New flights always start Private.
    let defaultVisibility: FlightVisibility = .default

    init(pilotName: String = "Alex Rivera",
         homeAirport: Airport = MockAirports.ksql,
         hideHomeAirport: Bool = true,
         defaultTrimNM: Double = 1.0) {
        self.pilotName = pilotName
        self.homeAirport = homeAirport
        self.hideHomeAirport = hideHomeAirport
        self.defaultTrimNM = defaultTrimNM
    }
}
