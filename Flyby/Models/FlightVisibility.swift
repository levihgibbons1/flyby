/// Who can see a flight. New flights are always `.private` (privacy-sharing.md).
enum FlightVisibility: String, CaseIterable, Identifiable, Hashable, Sendable {
    case `private`
    case followers
    case `public`

    static let `default`: FlightVisibility = .private

    var id: String { rawValue }

    var title: String {
        switch self {
        case .private: "Private"
        case .followers: "Followers"
        case .public: "Public"
        }
    }

    var systemImage: String {
        switch self {
        case .private: "lock.fill"
        case .followers: "person.2.fill"
        case .public: "globe.americas.fill"
        }
    }

    var summary: String {
        switch self {
        case .private: "Only you"
        case .followers: "Pilots who follow you"
        case .public: "Anyone on Flyby"
        }
    }
}
