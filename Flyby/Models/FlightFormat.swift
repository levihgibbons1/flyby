import Foundation

/// Display formats for flight values (DESIGN_SYSTEM.md §4: h:mm durations,
/// decimal logbook hours, nm, ft).
enum FlightFormat {
    /// "0:58", "12:05".
    static func duration(_ interval: TimeInterval) -> String {
        let minutes = max(0, Int((interval / 60).rounded()))
        return "\(minutes / 60):" + String(format: "%02d", minutes % 60)
    }

    /// "58 minutes", "1 hour, 12 minutes".
    static func spokenDuration(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        return formatter.string(from: max(0, interval)) ?? duration(interval)
    }

    /// Decimal logbook hours, "12.4".
    static func hours(_ interval: TimeInterval) -> String {
        (interval / 3600).formatted(.number.precision(.fractionLength(1)))
    }

    /// Whole nautical miles, "135".
    static func distance(_ nauticalMiles: Double) -> String {
        nauticalMiles.formatted(.number.precision(.fractionLength(0)))
    }

    /// "11,500".
    static func altitude(_ feet: Int) -> String {
        feet.formatted(.number)
    }
}
