import SwiftUI

/// Home, journal mode (pre-social). Placeholder until the Flight model (#4)
/// and design system (#3) land.
struct HomeView: View {
    var onLogFlight: () -> Void = {}
    var onShowAllFlights: () -> Void = {}

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("2026 so far")
                        .font(.headline)
                    Text("Your year in flight will appear here: hours, flights, airports and distance.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Label("Only you", systemImage: "lock.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                .accessibilityElement(children: .combine)
            }

            Section("Recent flights") {
                ForEach(PlaceholderFlights.recent) { flight in
                    PlaceholderFlightRow(flight: flight)
                }
                Button("All flights", action: onShowAllFlights)
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("home.allFlights")
            }

            Section {
                Button(action: onLogFlight) {
                    Label("Log a Flight", systemImage: "plus")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .flybyGlassProminentButtonStyle()
                .accessibilityIdentifier("home.logFlight")
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
        }
        .navigationTitle("Home")
    }
}

#Preview {
    NavigationStack { HomeView() }
}
