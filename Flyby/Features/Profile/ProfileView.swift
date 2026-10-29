import SwiftUI

/// Profile: totals, aircraft, and a link to Settings (privacy + about).
struct ProfileView: View {
    @Environment(FlightStore.self) private var store
    @Environment(ProfileStore.self) private var profile
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        // Stack the avatar above the text at accessibility sizes so the text keeps the full width.
        let headerLayout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(spacing: 12))
        let totals = store.totals()
        List {
            Section {
                headerLayout {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading) {
                        Text(profile.pilotName)
                            .font(.headline)
                        // Region only: the precise home field is never shown on the profile.
                        Text("Home base: \(profile.homeAirport.region)")
                            .font(.subheadline)
                            .foregroundStyle(Color.label2)
                    }
                }
                .accessibilityElement(children: .combine)
            }

            Section {
                FactRow("Flights", value: "\(totals.count)")
                    .accessibilityIdentifier("profile.stat.flights")
                FactRow("Hours", value: FlightFormat.hours(totals.flightTime))
                    .accessibilityIdentifier("profile.stat.hours")
                FactRow("Airports", value: "\(totals.airports)")
                    .accessibilityIdentifier("profile.stat.airports")
                FactRow("Distance", value: "\(FlightFormat.distance(totals.distanceNM)) nm")
                    .accessibilityIdentifier("profile.stat.distance")
            } header: {
                SectionHeaderText("All time")
            }

            if !store.aircraft.isEmpty {
                Section {
                    ForEach(store.aircraft, id: \.self) { Text($0) }
                } header: {
                    SectionHeaderText("Aircraft")
                }
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
                .accessibilityIdentifier("profile.settings")
            }
        }
    }
}

#Preview {
    NavigationStack { ProfileView() }
        .environment(FlightStore())
        .environment(ProfileStore())
}
