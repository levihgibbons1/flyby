import SwiftUI

/// Home, journal mode (pre-social): this year's totals and recent flights.
struct HomeView: View {
    var onLogFlight: () -> Void = {}
    var onShowAllFlights: () -> Void = {}

    @Environment(FlightStore.self) private var store

    var body: some View {
        Group {
            if store.flights.isEmpty {
                ContentUnavailableView {
                    Label("Log your first flight", systemImage: "airplane")
                        .accessibilityIdentifier("empty.state")
                } description: {
                    Text("Enter a flight by hand. It stays private unless you choose otherwise.")
                } actions: {
                    Button("Log a Flight", action: onLogFlight)
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("empty.action")
                }
            } else {
                journal
            }
        }
        .navigationTitle("Home")
        .flightDestination()
    }

    private var journal: some View {
        let year = Calendar.current.component(.year, from: .now)
        let totals = store.totals(year: year)
        return List {
            Section {
                FactRow("Hours", value: FlightFormat.hours(totals.flightTime))
                FactRow("Flights", value: "\(totals.count)")
                FactRow("Airports", value: "\(totals.airports)")
                FactRow("Distance", value: "\(FlightFormat.distance(totals.distanceNM)) nm")
            } header: {
                HStack {
                    SectionHeaderText("\(String(year)) so far")
                    Spacer()
                    Label("Only you", systemImage: "lock.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.label2)
                }
            }

            Section {
                ForEach(store.flights.prefix(3)) { flight in
                    NavigationLink(value: FlightLink(id: flight.id)) {
                        FlightRow(flight: flight)
                    }
                    .accessibilityIdentifier("home.row.\(flight.id)")
                }
                Button("All flights", action: onShowAllFlights)
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("home.allFlights")
            } header: {
                SectionHeaderText("Recent flights")
            }
        }
    }
}

#Preview {
    NavigationStack { HomeView() }
        .environment(FlightStore())
}

#Preview("Empty") {
    NavigationStack { HomeView() }
        .environment(FlightStore(flights: []))
}
