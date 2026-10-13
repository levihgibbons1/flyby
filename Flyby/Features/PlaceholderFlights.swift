import SwiftUI

// Temporary static content so each tab has something to show.
// Replaced by the Flight model and MockData store in #4.

struct PlaceholderFlight: Identifiable, Hashable {
    let id: String
    let departure: String
    let arrival: String
    let date: String
    let aircraft: String

    var routeTitle: String { "\(departure) → \(arrival)" }
}

enum PlaceholderFlights {
    static let recent: [PlaceholderFlight] = [
        PlaceholderFlight(id: "1", departure: "KPAO", arrival: "KMRY", date: "Oct 4", aircraft: "C172S"),
        PlaceholderFlight(id: "2", departure: "KSQL", arrival: "KTVL", date: "Sep 19", aircraft: "SR22"),
        PlaceholderFlight(id: "3", departure: "KHAF", arrival: "KSQL", date: "Sep 7", aircraft: "C172S"),
    ]

    static let airports: [(code: String, name: String)] = [
        ("KSQL", "San Carlos"),
        ("KPAO", "Palo Alto"),
        ("KMRY", "Monterey Regional"),
        ("KTVL", "Lake Tahoe"),
        ("KHAF", "Half Moon Bay"),
    ]
}

struct PlaceholderFlightRow: View {
    let flight: PlaceholderFlight

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(flight.routeTitle)
                    .font(.body.monospaced().weight(.semibold))
                Text("\(flight.date) · \(flight.aircraft)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Label("Private", systemImage: "lock.fill")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: 44)
        .accessibilityElement(children: .combine)
    }
}
