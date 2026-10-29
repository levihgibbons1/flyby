import SwiftUI

/// Explore: airports visited (discovery, not planning).
struct ExploreView: View {
    @Environment(FlightStore.self) private var store

    var body: some View {
        List {
            Section {
                Text("Airports you've flown to and from. Wishlists and airport pages come later.")
                    .font(.subheadline)
                    .foregroundStyle(Color.label2)
            }

            Section {
                ForEach(store.visitedAirports, id: \.airport) { entry in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(entry.airport.icao)
                            .font(.body.monospaced().weight(.semibold))
                            .fixedSize()
                        Text(entry.airport.name)
                            .foregroundStyle(Color.label2)
                            .fixedSize(horizontal: false, vertical: true)
                            .layoutPriority(1)
                        Spacer(minLength: 8)
                        Text(entry.visits == 1 ? "1 visit" : "\(entry.visits) visits")
                            .font(.subheadline)
                            .foregroundStyle(Color.label2)
                            .fixedSize()
                    }
                    .frame(minHeight: 44)
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("explore.airport.\(entry.airport.icao)")
                }
            } header: {
                SectionHeaderText("Visited")
            }
        }
        .navigationTitle("Explore")
    }
}

#Preview {
    NavigationStack { ExploreView() }
        .environment(FlightStore())
}
