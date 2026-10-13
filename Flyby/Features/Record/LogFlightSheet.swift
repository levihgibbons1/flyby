import SwiftUI

/// Log a Flight, presented from the Record tab. Placeholder until the
/// manual logging form (#6). Flyby never records live position.
struct LogFlightSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label("Manual flight logging is coming in the next build.", systemImage: "square.and.pencil")
                    Label("Flyby never records your live position.", systemImage: "location.slash")
                }

                Section {
                    Label("Private by default. Only you can see a new flight.", systemImage: "lock.fill")
                } footer: {
                    Text("Flyby is a journal · Not for navigation")
                }
            }
            .navigationTitle("Log a Flight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") { dismiss() }
                        .accessibilityIdentifier("log.cancel")
                }
            }
        }
        .accessibilityIdentifier("log.sheet")
    }
}

#Preview {
    LogFlightSheet()
}
