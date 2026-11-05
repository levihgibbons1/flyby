import Foundation

/// One photo on a flight. Sprint 1 has no camera roll: `symbolName` is a
/// stand-in image, drawn by the detail carousel.
struct FlightPhoto: Identifiable, Hashable, Sendable {
    var id: String
    var caption: String
    /// SF Symbol used until real photos exist.
    var symbolName: String
    var style: Style

    enum Style: Hashable, Sendable {
        case coast
        case sierra
        case sunset
        case lake
        case field
        case cabin
    }
}
