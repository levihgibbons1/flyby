import Foundation

/// The five root tabs, in tab-bar order (DESIGN_SYSTEM.md §7).
enum AppTab: Hashable, CaseIterable {
    case home
    case explore
    case record
    case flights
    case profile

    var title: String {
        switch self {
        case .home: "Home"
        case .explore: "Explore"
        case .record: "Record"
        case .flights: "Flights"
        case .profile: "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house.fill"
        case .explore: "globe.americas.fill"
        case .record: "plus.circle.fill"
        case .flights: "book.closed.fill"
        case .profile: "person.crop.circle.fill"
        }
    }

    /// Stable identifier for UI tests (`tab.home`, `tab.explore`, …).
    var accessibilityID: String { "tab.\(String(describing: self))" }

    /// Record is an action, not a destination: selecting it presents the
    /// Log a Flight sheet and the previous tab stays selected.
    var isAction: Bool { self == .record }
}
