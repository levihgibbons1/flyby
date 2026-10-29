import SwiftUI
import UIKit

/// SwiftUI does not forward `.accessibilityIdentifier` from a `.tabItem` label
/// to the iPhone tab button, and the iOS 18 `Tab` API does not either (the
/// identifier never appears on the tab's accessibility element). Ids are
/// therefore written onto each public `UITabBarItem`.
///
/// On iOS 26 that write is not enough by itself. The glass tab bar copies the
/// item identifier when it creates the button, and this installer usually runs
/// after that copy, so XCUITest intermittently never sees `tab.home`. The same
/// id is applied to the button view — matched by its visible title, not by a
/// private tab-button class — on later layout passes until the button exists.
struct TabBarAccessibilityIdentifiers: UIViewControllerRepresentable {
    let titles: [String]
    let identifiers: [String]

    func makeUIViewController(context: Context) -> InstallerViewController {
        InstallerViewController(titles: titles, identifiers: identifiers)
    }

    func updateUIViewController(_ controller: InstallerViewController, context: Context) {
        controller.titles = titles
        controller.identifiers = identifiers
        controller.install()
    }

    final class InstallerViewController: UIViewController {
        var titles: [String]
        var identifiers: [String]
        private var isInstalling = false
        private var retriesScheduled = false

        init(titles: [String], identifiers: [String]) {
            self.titles = titles
            self.identifiers = identifiers
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { nil }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            install()
            scheduleRetries()
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            install()
        }

        /// The glass buttons are created on a later turn than `viewDidAppear`.
        /// Re-apply until they exist; the test waits several seconds for `tab.home`.
        private func scheduleRetries() {
            guard !retriesScheduled else { return }
            retriesScheduled = true
            for delay in [0.05, 0.2, 0.5, 1.0, 2.0, 3.5] {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                    self?.install()
                }
            }
        }

        func install() {
            guard !isInstalling, let tabBarController = findTabBarController() else { return }
            isInstalling = true
            defer { isInstalling = false }

            let tabBar = tabBarController.tabBar
            if let items = tabBar.items {
                for (item, identifier) in zip(items, identifiers) where item.accessibilityIdentifier != identifier {
                    item.accessibilityIdentifier = identifier
                }
            }

            guard titles.count == identifiers.count, tabBarController.isViewLoaded else { return }
            let root: UIView = tabBarController.view
            let byTitle = Dictionary(uniqueKeysWithValues: zip(titles, identifiers))
            // The floating glass bar sits slightly outside `tabBar.bounds`.
            let barFrame = tabBar.convert(tabBar.bounds, to: root).insetBy(dx: -32, dy: -80)
            stamp(tabBar, tabBar: tabBar, root: root, barFrame: barFrame, byTitle: byTitle)
            // iOS 26 sometimes hosts the glass buttons beside the tab bar, in a
            // short container. Don't walk the screen: a full-height sibling is content.
            if let container = tabBar.superview {
                for sibling in container.subviews where sibling !== tabBar {
                    let frame = sibling.convert(sibling.bounds, to: root)
                    if frame.intersects(barFrame) && frame.height < 160 {
                        stamp(sibling, tabBar: tabBar, root: root, barFrame: barFrame, byTitle: byTitle)
                    }
                }
            }
        }

        /// Sets the id on the tab button itself. iOS 26's glass button is not
        /// always a `UIControl`, so any view with a tab title qualifies when it
        /// lives in the tab bar or overlaps the bar's frame.
        private func stamp(_ view: UIView, tabBar: UITabBar, root: UIView, barFrame: CGRect, byTitle: [String: String]) {
            if view !== tabBar,
               let title = view.accessibilityLabel,
               let identifier = byTitle[title],
               view.accessibilityIdentifier != identifier {
                let frame = view.convert(view.bounds, to: root)
                // Tab buttons are small. Skip full-screen containers whose
                // accessibility label happens to be the selected tab's title.
                let buttonSized = frame.width > 24 && frame.width < 200
                    && frame.height > 16 && frame.height < 96
                if buttonSized && (view.isDescendant(of: tabBar) || frame.intersects(barFrame)) {
                    view.accessibilityIdentifier = identifier
                }
            }
            for subview in view.subviews {
                stamp(subview, tabBar: tabBar, root: root, barFrame: barFrame, byTitle: byTitle)
            }
        }

        private func findTabBarController() -> UITabBarController? {
            if let tabBarController { return tabBarController }
            return Self.search(view.window?.rootViewController)
        }

        private static func search(_ controller: UIViewController?) -> UITabBarController? {
            guard let controller else { return nil }
            if let tabBarController = controller as? UITabBarController { return tabBarController }
            for child in controller.children {
                if let found = search(child) { return found }
            }
            return search(controller.presentedViewController)
        }
    }
}
