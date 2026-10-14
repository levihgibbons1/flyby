import SwiftUI

/// Flights: the pilot's logbook, grouped by month.
struct FlightsView: View {
    var onLogFlight: () -> Void = {}

    @Environment(FlightStore.self) private var store

    var body: some View {
        Group {
            if store.flights.isEmpty {
                ContentUnavailableView {
                    Label("No flights yet", systemImage: "book.closed")
                        .accessibilityIdentifier("empty.state")
                } description: {
                    Text("Logged flights appear here, grouped by month.")
                } actions: {
                    Button("Log a Flight", action: onLogFlight)
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("empty.action")
                }
            } else {
                List {
                    ForEach(store.monthSections()) { section in
                        Section {
                            ForEach(section.flights) { flight in
                                NavigationLink(value: FlightLink(id: flight.id)) {
                                    FlightRow(flight: flight)
                                }
                                .accessibilityIdentifier("flights.row.\(flight.id)")
                            }
                        } header: {
                            SectionHeaderText(section.month.formatted(.dateTime.month(.wide).year()))
                        }
                    }
                }
                .accessibilityIdentifier("flights.list")
            }
        }
        .navigationTitle("Flights")
        .flightDestination()
    }
}

#Preview {
    NavigationStack { FlightsView() }
        .environment(FlightStore())
}
