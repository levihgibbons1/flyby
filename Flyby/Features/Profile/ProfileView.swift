import SwiftUI

/// Profile: totals, aircraft, achievements, settings & privacy.
/// Placeholder until the pilot model (#4) lands.
struct ProfileView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        // Stack the avatar above the text at accessibility sizes so the text keeps the full width.
        let headerLayout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(spacing: 12))
        List {
            Section {
                headerLayout {
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
