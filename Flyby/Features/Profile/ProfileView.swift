import SwiftUI

/// Profile: totals, aircraft, achievements, settings & privacy.
/// Placeholder until the pilot model (#4) lands.
struct ProfileView: View {
    var body: some View {
        List {
            Section {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading) {
                        Text("Pilot")
                            .font(.headline)
                        Text("Totals, aircraft and achievements will appear here.")
                            .font(.subheadline)
                            .foregroundStyle(Color.label2)
                    }
                }
                .accessibilityElement(children: .combine)
            }

            Section {
                Label("New flights are Private by default", systemImage: "lock.fill")
            } header: {
                SectionHeaderText("Privacy")
            }

            Section {
                Label("Flyby is a flight journal. Not for navigation.", systemImage: "info.circle")
                    .accessibilityIdentifier("profile.disclaimer")
            } header: {
                SectionHeaderText("About")
            }
        }
        .navigationTitle("Profile")
    }
}

#Preview {
    NavigationStack { ProfileView() }
}
