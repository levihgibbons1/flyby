import SwiftUI
import UIKit

/// SwiftUI doesn't forward `.accessibilityIdentifier` from a `.tabItem` to the
/// tab bar button, so UI tests can't find `tab.home` etc. This installs the
/// identifiers on the hosting `UITabBarController`'s items, in tab order.
struct TabBarAccessibilityIdentifiers: UIViewControllerRepresentable {
    let identifiers: [String]

    func makeUIViewController(context: Context) -> InstallerViewController {
        InstallerViewController(identifiers: identifiers)
    }

    func updateUIViewController(_ controller: InstallerViewController, context: Context) {
        controller.identifiers = identifiers
        controller.install()
    }

    final class InstallerViewController: UIViewController {
        var identifiers: [String]

        init(identifiers: [String]) {
            self.identifiers = identifiers
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { nil }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            install()
        }

        func install() {
            guard let tabBarController = findTabBarController(),
                  let items = tabBarController.tabBar.items else { return }
            for (item, identifier) in zip(items, identifiers) {
                item.accessibilityIdentifier = identifier
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
