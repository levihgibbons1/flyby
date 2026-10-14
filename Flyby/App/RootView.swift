import SwiftUI

/// Placeholder root view. Replaced by the main TabView in #2.
struct RootView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "airplane")
                .font(.largeTitle)
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
            Text("Flyby")
                .font(.largeTitle.bold())
            Text("Your flight journal")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("root.placeholder")
    }
}

#Preview {
    RootView()
}
