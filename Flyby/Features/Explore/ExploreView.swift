import SwiftUI

/// Explore: airports visited and wishlisted (discovery, not planning).
/// Placeholder until the airport map lands.
struct ExploreView: View {
    var body: some View {
        List {
            Section {
                Text("Discover airports you've visited and the ones on your wishlist.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Visited") {
                ForEach(PlaceholderFlights.airports, id: \.code) { airport in
                    HStack(spacing: 12) {
                        Text(airport.code)
                            .font(.body.monospaced().weight(.semibold))
                        Text(airport.name)
                            .foregroundStyle(.secondary)
                    }
                    .frame(minHeight: 44)
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .navigationTitle("Explore")
    }
}

#Preview {
    NavigationStack { ExploreView() }
}
