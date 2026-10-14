import XCTest

/// The "Not for navigation" disclaimer must appear on About (Profile) and the
/// Log a Flight sheet (CLAUDE.md, Privacy).
final class DisclaimerUITests: XCTestCase {
    private let disclaimer = "Personal journal · Not for navigation"
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["tab.home"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testAboutShowsDisclaimer() throws {
        app.tabBars.buttons["tab.profile"].tap()
        let element = app.staticTexts.matching(identifier: "about.disclaimer").firstMatch
        XCTAssertTrue(element.waitForExistence(timeout: 3))
        XCTAssertTrue(element.label.contains(disclaimer), element.label)
        XCTAssertFalse(app.descendants(matching: .any)["profile.disclaimer"].exists)
    }

    @MainActor
    func testLogFlightSheetShowsDisclaimer() throws {
        app.tabBars.buttons["tab.record"].tap()
        let element = app.staticTexts.matching(identifier: "log.disclaimer").firstMatch
        XCTAssertTrue(element.waitForExistence(timeout: 3))
        XCTAssertTrue(element.label.contains(disclaimer), element.label)
    }
}
