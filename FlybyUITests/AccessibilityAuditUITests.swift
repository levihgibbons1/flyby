import XCTest

/// Runs Apple's automated accessibility audit (the same checks as Accessibility
/// Inspector) on every destination tab and the Log a Flight sheet, in Light,
/// Dark, and at accessibility text size AX3.
///
/// The audit's own Dynamic Type check is excluded: on scrolling Lists it flags
/// rows that its enlarged text pushes below the screen, even though they scale
/// (verified at AX5 on iOS 17.5 and 26.2, Oct 14, 2026). Dynamic Type is covered
/// instead by running the full audit, including clipped text, at AX3.
final class AccessibilityAuditUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        XCUIDevice.shared.appearance = .light
    }

    private func launch(textSize: String? = nil) {
        if let textSize {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", textSize]
        }
        app.launch()
        app.requireTabBar()
    }

    /// Audits one screen. Real issues are returned (not thrown) so a run reports
    /// every screen, and the element text is in the XCTest failure line CI keeps.
    /// One retry covers the iOS 26 simulator timeout (XCTest code -56, "Audit
    /// failed to complete in time") which can happen before any issue is produced.
    @MainActor
    private func audit(screen: String) throws -> [String] {
        let tabBarFrame = app.tabBars.firstMatch.frame
        let types = XCUIAccessibilityAuditType.all.subtracting(.dynamicType)
        var lastError: Error?
        for attempt in 1...2 {
            do {
                var found: [String] = []
                try app.performAccessibilityAudit(for: types) { issue in
                    let element = issue.element.map {
                        "'\($0.label)' [\($0.identifier)] y=\(Int($0.frame.minY))"
                    } ?? "(no element)"
                    let ignored = Self.isKnownFalsePositive(issue)
                        || Self.isContrastBehindTabBar(issue, tabBarFrame: tabBarFrame)
                    let description = "\(issue.compactDescription): \(element)"
                    print("ACCESSIBILITY AUDIT\(ignored ? " (known false positive, ignored)" : ""): \(screen): \(description)")
                    if !ignored {
                        found.append("\(screen): \(description)")
                    }
                    return true
                }
                return found
            } catch {
                lastError = error
                let timedOut = String(describing: error).contains("complete in time")
                if timedOut && attempt == 1 { continue }
                throw error
            }
        }
        throw lastError ?? CocoaError(.coderInvalidValue)
    }

    /// Content scrolls underneath the translucent tab bar (by design), so contrast
    /// measured there is through the bar, not the real text contrast.
    ///
    /// The bar's blur extends above its accessibility frame. On iOS 26 at AX3,
    /// the Profile "Aircraft" header on iPhone 15 Pro Max sits in that band and
    /// the audit samples the glass, not the grouped background (label2 on that
    /// background is 7.1:1 / 8.6:1). The same header passes at the default size
    /// and on iOS 17.5, where the bar doesn't cover it.
    private static func isContrastBehindTabBar(_ issue: XCUIAccessibilityAuditIssue,
                                               tabBarFrame: CGRect) -> Bool {
        guard issue.auditType == .contrast else { return false }
        guard let element = issue.element else {
            // No element to locate; seen only alongside rows under the tab bar.
            return true
        }
        var band = tabBarFrame
        band.origin.y -= 48
        band.size.height += 48
        return element.frame.intersects(band)
    }

    /// Audit findings checked by hand and found not to reproduce. Keep this list
    /// short and specific so new issues still fail the test.
    private static func isKnownFalsePositive(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
        let label = issue.element?.label
        switch issue.auditType {
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
    private func auditAllScreens() throws {
        var failures: [String] = []
        for id in ["tab.home", "tab.explore", "tab.flights", "tab.profile"] {
            app.tabBars.buttons[id].tap()
            failures += try audit(screen: id)
        }
        app.buttons["profile.settings"].tap()
        XCTAssertTrue(app.switches["settings.hideHome"].waitForExistence(timeout: 3))
        failures += try audit(screen: "settings")
        app.tabBars.buttons["tab.record"].tap()
        XCTAssertTrue(app.navigationBars["Log a Flight"].waitForExistence(timeout: 3))
        failures += try audit(screen: "log")
        if !failures.isEmpty {
            XCTFail(failures.joined(separator: " || "))
        }
    }

    @MainActor
    func testScreensPassAccessibilityAuditInLight() throws {
        launch()
        try auditAllScreens()
    }

    @MainActor
    func testScreensPassAccessibilityAuditInDark() throws {
        XCUIDevice.shared.appearance = .dark
        launch()
        try auditAllScreens()
    }

    @MainActor
    func testScreensPassAccessibilityAuditAtAX3() throws {
        launch(textSize: "UICTContentSizeCategoryAccessibilityXL")
        try auditAllScreens()
    }
}
