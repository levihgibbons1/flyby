import CoreGraphics
import Foundation

/// Story (1080×1920) and square (1080×1080) export sizes.
/// The card is laid out at 360 pt and rendered at 3×.
enum RecapCanvas: String, CaseIterable, Identifiable {
    case story
    case square

    var id: String { rawValue }

    var title: String {
        switch self {
        case .story: "Story"
        case .square: "Square"
        }
    }

    /// Point size of the SwiftUI card. ImageRenderer multiplies by `scale`.
    var pointSize: CGSize {
        switch self {
        case .story: CGSize(width: 360, height: 640)
        case .square: CGSize(width: 360, height: 360)
        }
    }

    var scale: CGFloat { 3 }

    var pixelSize: CGSize {
        CGSize(width: pointSize.width * scale, height: pointSize.height * scale)
    }
}

/// This share's privacy choices. A value, so changing it cannot write the profile.
struct RecapPrivacySelection: Equatable {
    var hideHomeAirport: Bool
    var trimEnds: Bool
    var canvas: RecapCanvas
    var home: Airport
    var trimDistanceNM: Double
    /// The profile setting at the moment the share opened. Not updated if the toggle moves.
    var savedHideHomeDefault: Bool

    init(profile: ProfileStore) {
        hideHomeAirport = profile.hideHomeAirport
        trimEnds = true
        canvas = .story
        home = profile.homeAirport
        trimDistanceNM = profile.defaultTrimNM
        savedHideHomeDefault = profile.hideHomeAirport
    }
}

/// Everything the recap card is allowed to print.
/// Built from `TrackPrivacy`, so the home field's name and ICAO never get onto the card
/// while hiding is on. The view renders these strings and no others.
struct RecapCardModel: Equatable {
    static let brand = "Flyby"
    static let disclaimer = "Personal journal · Not for navigation"

    var routeTitle: String
    var routeSpoken: String
    var homeNote: String?
    var dateText: String
    var aircraft: String
    var durationText: String
    var distanceText: String
    var altitudeText: String
    var note: String?
    var points: [TrackPoint]
    var approximate: Bool
    var canvas: RecapCanvas

    static func make(flight: Flight, selection: RecapPrivacySelection) -> RecapCardModel {
        let route = TrackPrivacy.hideHomeAirport(flight,
                                                 home: selection.home,
                                                 enabled: selection.hideHomeAirport,
                                                 trimEnds: selection.trimEnds,
                                                 distance: selection.trimDistanceNM)
        let altitudeText: String
        if let feet = flight.maxAltitudeFeet {
            altitudeText = "\(FlightFormat.altitude(feet)) ft"
        } else {
            altitudeText = "—"
        }
        let aircraft = flight.aircraftType.trimmingCharacters(in: .whitespacesAndNewlines)
        let note: String?
        if route.unavailable {
            note = "Route unavailable"
        } else if route.tooShortToTrim {
            note = TrackPrivacy.shortTrackNote
        } else if route.approximate {
            note = "Approximate route"
        } else {
            note = nil
        }
        return RecapCardModel(
            routeTitle: "\(route.departure.label) → \(route.arrival.label)",
            routeSpoken: "\(route.departure.spoken) to \(route.arrival.spoken)",
            homeNote: route.homeFieldHidden ? TrackPrivacy.homeFieldNote : nil,
            dateText: flight.date.formatted(.dateTime.month(.wide).day().year()),
            aircraft: aircraft.isEmpty ? "Aircraft not recorded" : aircraft,
            durationText: FlightFormat.duration(flight.flightDuration),
            distanceText: "\(FlightFormat.distance(flight.distanceNM)) nm",
            altitudeText: altitudeText,
            note: note,
            points: route.points,
            approximate: route.approximate && !route.tooShortToTrim,
            canvas: selection.canvas
        )
    }

    /// Every string the card shows, including the spoken route, for the privacy test.
    var displayedCopy: [String] {
        var lines = [
            Self.brand,
            routeTitle,
            routeSpoken,
            dateText,
            aircraft,
            "Flight time",
            durationText,
            "Distance",
            distanceText,
            "Max altitude",
            altitudeText,
            Self.disclaimer,
        ]
        if let homeNote { lines.append(homeNote) }
        if let note { lines.append(note) }
        return lines
    }

    var visibleText: String { displayedCopy.joined(separator: "\n") }
}
