import SwiftUI

/// Compact journal row: route, date · aircraft · time, and visibility.
/// VoiceOver reads it as one sentence (accessibility.md §5).
struct FlightRow: View {
    let flight: Flight

    var body: some View {
        // Side by side when it fits; stacked when the date line would truncate
        // (iPhone SE, and every phone at accessibility sizes).
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: 8) {
                textColumn
                Spacer(minLength: 8)
                VisibilityLabel(visibility: flight.visibility)
            }
            .fixedSize(horizontal: true, vertical: false)

            VStack(alignment: .leading, spacing: 4) {
                textColumn
                VisibilityLabel(visibility: flight.visibility)
            }
        }
        .frame(minHeight: 44)
        // Otherwise the divider starts under the visibility label's text.
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(flight.accessibilitySummary)
    }

    private var textColumn: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(flight.routeTitle)
                .font(.body.monospaced().weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
            Text(detailLine)
                .font(.subheadline)
                .foregroundStyle(Color.label2)
                .fixedSize(horizontal: false, vertical: true)
        }
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
