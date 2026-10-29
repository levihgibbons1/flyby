import SwiftUI

/// Settings: Privacy (global Hide home airport, On by default) and About.
struct SettingsView: View {
    @Environment(ProfileStore.self) private var profile

    var body: some View {
        @Bindable var profile = profile
        List {
            Section {
                Toggle("Hide home airport", isOn: $profile.hideHomeAirport)
                    .accessibilityIdentifier("settings.hideHome")
                FactRow("Home airport (only you)",
                        value: "\(profile.homeAirport.icao) · \(profile.homeAirport.name)")
                    .accessibilityIdentifier("settings.homeAirport")
                FactRow("New flights", value: profile.defaultVisibility.title)
                    .accessibilityIdentifier("settings.defaultVisibility")
                Stepper(value: $profile.defaultTrimNM, in: 0.5...3, step: 0.5) {
                    FactRow("Trim shared tracks",
                            value: "\(profile.defaultTrimNM.formatted(.number.precision(.fractionLength(1)))) nm")
                }
                .accessibilityIdentifier("settings.trim")
            } header: {
                SectionHeaderText("Privacy")
            } footer: {
                // iOS 17 sizes this footer a line short, so the audit reports the
                // last line as text clipped. fixedSize lets it take its full height.
                Text("When on, shares show \(profile.homeAirport.region) instead of your home airport and trim the track near it. You can change this for a single share.")
                    .font(.footnote)
                    .foregroundStyle(Color.label2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Personal journal · Not for navigation", systemImage: "info.circle")
                        .font(.headline)
                        .accessibilityIdentifier("about.disclaimer")
                    Text("Flyby isn't a certified logbook, and it isn't for navigation, flight planning or any operational use. Recorded altitudes, speeds and routes are approximate.")
                        .font(.subheadline)
                        .foregroundStyle(Color.label2)
                }
                .padding(.vertical, 4)
            } header: {
                SectionHeaderText("About")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { SettingsView() }
        .environment(ProfileStore())
}
