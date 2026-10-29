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
                // In the section body, not the header. iOS 17 clips a header
                // that is taller than one line ("2026 so far" plus "Only you"),
                // which the accessibility audit reports as text clipped.
                yearSummary(year)
                FactRow("Hours", value: FlightFormat.hours(totals.flightTime))
                FactRow("Flights", value: "\(totals.count)")
                FactRow("Airports", value: "\(totals.airports)")
                FactRow("Distance", value: "\(FlightFormat.distance(totals.distanceNM)) nm")
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

    /// Year title with the "Only you" privacy pill. Stacks when the row is too
    /// narrow (iPhone SE at AX3) instead of truncating either label.
    private func yearSummary(_ year: Int) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                yearTitle(year)
                Spacer(minLength: 8)
                onlyYou
            }
            .fixedSize(horizontal: true, vertical: false)

            VStack(alignment: .leading, spacing: 4) {
                yearTitle(year)
                onlyYou
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func yearTitle(_ year: Int) -> some View {
        Text("\(String(year)) so far")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.label2)
            .accessibilityAddTraits(.isHeader)
    }

    private var onlyYou: some View {
        Label("Only you", systemImage: "lock.fill")
            .font(.caption.weight(.medium))
            .foregroundStyle(Color.label2)
            .fixedSize()
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
