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
        try app.performAccessibilityAudit { issue in
            let element = issue.element.map { "'\($0.label)' \($0.frame)" } ?? "(no element)"
            let ignored = Self.isKnownFalsePositive(issue)
            print("ACCESSIBILITY AUDIT\(ignored ? " (known false positive, ignored)" : ""): \(issue.compactDescription): \(element)")
            return ignored
        }
    }

    /// Audit findings checked by hand and found not to reproduce. Each was verified
    /// with screenshots on iPhone SE at AX3 and AX5 (Oct 13, 2026). Keep this list
    /// short and specific so new issues still fail the test.
    private static func isKnownFalsePositive(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
        let label = issue.element?.label
        switch issue.auditType {
        case .dynamicType:
            // System .glassProminent button style. The label scales through AX5.
            return label == "Log a Flight"
        case .textClipped:
            // nil element: system chrome (the tab bar uses the Large Content Viewer
            // instead of scaling). The sheet row wraps fully at AX5.
            return label == nil || label == "Flyby never records your live position."
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
