import SwiftUI

/// Flights: the pilot's logbook list. Placeholder until the Flight model (#4)
/// and Flight Detail (#5) land.
struct FlightsView: View {
    var body: some View {
        List {
            Section("October 2026") {
                ForEach(PlaceholderFlights.recent) { flight in
                    NavigationLink(value: flight) {
                        PlaceholderFlightRow(flight: flight)
                    }
                    .accessibilityIdentifier("flights.row.\(flight.id)")
                }
            }
        }
        .navigationTitle("Flights")
        .navigationDestination(for: PlaceholderFlight.self) { flight in
            PlaceholderFlightDetail(flight: flight)
        }
    }
}

private struct PlaceholderFlightDetail: View {
    let flight: PlaceholderFlight

    var body: some View {
        List {
            Section {
                PlaceholderFlightRow(flight: flight)
            }
            Section {
                Text("The full Flight Detail map and stats arrive in #5.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(flight.routeTitle)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("flightDetail.placeholder")
    }
}

#Preview {
    NavigationStack { FlightsView() }
}
