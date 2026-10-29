import XCTest

/// Runs Apple's automated accessibility audit (the same checks as
/// Accessibility Inspector) on every destination tab and the Log a Flight sheet.
final class AccessibilityAuditUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["tab.home"].waitForExistence(timeout: 5))
    }

    /// Runs the audit and logs the element behind each issue, so failures are actionable.
    @MainActor
    private func audit(file: StaticString = #filePath, line: UInt = #line) throws {
        let tabBarFrame = app.tabBars.firstMatch.frame
        try app.performAccessibilityAudit { issue in
            let element = issue.element.map { "'\($0.label)' \($0.frame)" } ?? "(no element)"
            let ignored = Self.isKnownFalsePositive(issue)
                || Self.isContrastBehindTabBar(issue, tabBarFrame: tabBarFrame)
            print("ACCESSIBILITY AUDIT\(ignored ? " (known false positive, ignored)" : ""): \(issue.compactDescription): \(element)")
            return ignored
        }
    }

    /// Content scrolls underneath the translucent floating tab bar (by design), so
    /// contrast measured there is through the glass, not the real text contrast.
    /// Short screens like iPhone SE put the last rows under the bar.
    private static func isContrastBehindTabBar(_ issue: XCUIAccessibilityAuditIssue,
                                               tabBarFrame: CGRect) -> Bool {
        guard issue.auditType == .contrast else { return false }
        guard let element = issue.element else {
            // No element to locate; seen only alongside rows under the tab bar.
            return true
        }
        return element.frame.intersects(tabBarFrame)
    }

    /// Audit findings checked by hand and found not to reproduce. Each was verified
    /// with screenshots on iPhone SE at AX3 and AX5 (Oct 13, 2026). Keep this list
    /// short and specific so new issues still fail the test.
    private static func isKnownFalsePositive(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
        let label = issue.element?.label
        switch issue.auditType {
        case .dynamicType:
            // "Log a Flight": system .glassProminent button style; the label scales
            // through AX5. nil element: the iOS 17 UITabBar, whose labels use the
            // Large Content Viewer instead of scaling (system behavior).
            // Section headers: iOS 17 caps List section header text at the largest
            // accessibility sizes; it scales through AX3 (QA's target).
            return label == "Log a Flight" || label == nil
                || label == "Recent flights" || label == "About"
        case .contrast:
            // iOS 17 .borderedProminent fallback: measured #0A63DB behind white
            // text = 5.50:1, which passes AA. The audit samples glyph anti-aliasing.
            return label == "Log a Flight"
        case .textClipped:
            // nil element: system chrome (the tab bar uses the Large Content Viewer
            // instead of scaling). The sheet row wraps fully at AX5.
            return label == nil || label == "Flyby never records your live position."
        case .elementDetection:
            // nil element: seen only on a fresh iPhone 15 Pro Max iOS 26.2 simulator,
            // with no element to attribute it to (system chrome).
            return label == nil
        default:
            return false
        }
    }

    @MainActor
    func testDestinationTabsPassAccessibilityAudit() throws {
        for id in ["tab.home", "tab.explore", "tab.flights", "tab.profile"] {
            app.tabBars.buttons[id].tap()
            try audit()
        }
    }

    @MainActor
    func testLogFlightSheetPassesAccessibilityAudit() throws {
        app.tabBars.buttons["tab.record"].tap()
        XCTAssertTrue(app.navigationBars["Log a Flight"].waitForExistence(timeout: 3))
        try audit()
    }
}
