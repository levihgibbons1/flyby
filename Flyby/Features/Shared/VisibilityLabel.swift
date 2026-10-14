import SwiftUI

/// Icon + text, never color alone (DESIGN_SYSTEM.md §3).
struct VisibilityLabel: View {
    let visibility: FlightVisibility

    var body: some View {
        Label(visibility.title, systemImage: visibility.systemImage)
            .font(.caption.weight(.medium))
            .foregroundStyle(Color.label2)
            .accessibilityLabel("Visibility: \(visibility.title)")
    }
}
