import SwiftUI
import UIKit

/// Root navigation: Home · Explore · Record · Flights · Profile.
///
/// Each destination tab owns its own `NavigationStack`, so its navigation
/// state survives tab switches. Record never becomes the selected tab: the
/// selection binding intercepts it and presents the Log a Flight sheet instead
/// (navigation.md, "Record is an action, not a destination").
struct RootView: View {
    @State private var selection: AppTab = .home
    @State private var isLogFlightPresented = false

    var body: some View {
        TabView(selection: tabSelection) {
            NavigationStack {
                HomeView(
                    onLogFlight: { isLogFlightPresented = true },
                    onShowAllFlights: { selection = .flights }
                )
            }
            .tabItem { tabLabel(.home) }
            .tag(AppTab.home)

            NavigationStack {
                ExploreView()
            }
            .tabItem { tabLabel(.explore) }
            .tag(AppTab.explore)

            // Never shown: selecting Record presents the sheet instead.
            Color.clear
                .tabItem { tabLabel(.record) }
                .tag(AppTab.record)

            NavigationStack {
                FlightsView()
            }
            .tabItem { tabLabel(.flights) }
            .tag(AppTab.flights)

            NavigationStack {
                ProfileView()
            }
            .tabItem { tabLabel(.profile) }
            .tag(AppTab.profile)
        }
        .flybyTabBarMinimizeOnScroll()
        .background {
            TabBarAccessibilityIdentifiers(
                titles: AppTab.allCases.map(\.title),
                identifiers: AppTab.allCases.map(\.accessibilityID)
            )
            .frame(width: 0, height: 0)
            .accessibilityHidden(true)
        }
        .sheet(isPresented: $isLogFlightPresented) {
            LogFlightSheet()
        }
    }

    private var tabSelection: Binding<AppTab> {
        Binding(
            get: { selection },
            set: { newValue in
                if newValue.isAction {
                    isLogFlightPresented = true
                } else {
                    selection = newValue
                }
            }
        )
    }

    private func tabLabel(_ tab: AppTab) -> some View {
        Label {
            Text(tab.title)
        } icon: {
            if tab == .record {
                Self.recordIcon
            } else {
                Image(systemName: tab.systemImage)
            }
        }
        // Applied when the tab button is built. iOS 17 still needs
        // TabBarAccessibilityIdentifiers; the iOS 26 glass bar reads this one.
        .accessibilityIdentifier(tab.accessibilityID)
    }

    /// Record is the only tinted tab item (Flyby Blue). Tab bar items ignore
    /// SwiftUI foreground styles, so the tint is baked into the image.
    private static let recordIcon: Image = {
        guard let symbol = UIImage(systemName: AppTab.record.systemImage),
              let tint = UIColor(named: "AccentColor") else {
            return Image(systemName: AppTab.record.systemImage)
        }
        return Image(uiImage: symbol.withTintColor(tint, renderingMode: .alwaysOriginal))
    }()
}

#Preview {
    RootView()
}
