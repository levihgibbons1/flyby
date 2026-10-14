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
                        .foregroundStyle(Color.label2)
                    Label("Only you", systemImage: "lock.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.label2)
                }
                .padding(.vertical, 4)
                .accessibilityElement(children: .combine)
            }

            Section {
                ForEach(PlaceholderFlights.recent) { flight in
                    PlaceholderFlightRow(flight: flight)
                }
                Button("All flights", action: onShowAllFlights)
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("home.allFlights")
            } header: {
                SectionHeaderText("Recent flights")
            }

            Section {
                Button(action: onLogFlight) {
                    Text("Log a Flight")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical, 4)
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
