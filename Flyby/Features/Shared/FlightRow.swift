import SwiftUI

/// Compact journal row: route, date · aircraft · time, and visibility.
/// VoiceOver reads it as one sentence (accessibility.md §5).
struct FlightRow: View {
    let flight: Flight

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        // At accessibility sizes, stack the visibility under the route instead
        // of squeezing it into a narrow trailing column.
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
            : AnyLayout(HStackLayout())
        layout {
            VStack(alignment: .leading, spacing: 2) {
                Text(flight.routeTitle)
                    .font(.body.monospaced().weight(.semibold))
                Text(detailLine)
                    .font(.subheadline)
                    .foregroundStyle(Color.label2)
            }
            if !dynamicTypeSize.isAccessibilitySize {
                Spacer(minLength: 8)
            }
            VisibilityLabel(visibility: flight.visibility)
        }
        .frame(minHeight: 44)
        // Otherwise the divider starts under the visibility label's text.
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(flight.accessibilitySummary)
    }

    private var detailLine: String {
        let day = flight.date.formatted(.dateTime.month(.abbreviated).day())
        return "\(day) · \(flight.aircraftType) · \(FlightFormat.duration(flight.flightDuration))"
    }
}

/// Navigation value for opening a flight, so the destination always reads the
/// latest copy from the store.
struct FlightLink: Hashable {
    let id: Flight.ID
}

/// Pushes Flight Detail for a `FlightLink`.
struct FlightDestination: ViewModifier {
    @Environment(FlightStore.self) private var store

    func body(content: Content) -> some View {
        content.navigationDestination(for: FlightLink.self) { link in
            if let flight = store.flight(id: link.id) {
                FlightDetailView(flight: flight)
            } else {
                ContentUnavailableView("Flight not found", systemImage: "airplane",
                                       description: Text("This flight is no longer in your journal."))
            }
        }
    }
}

extension View {
    func flightDestination() -> some View { modifier(FlightDestination()) }
}
