import XCTest

/// The "Not for navigation" disclaimer must appear in Profile → Settings → About,
/// on the Log a Flight sheet, and on Flight Detail (CLAUDE.md, Privacy).
final class DisclaimerUITests: XCTestCase {
    private let disclaimer = "Personal journal · Not for navigation"
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        app.requireTabBar()
    }

    @MainActor
    func testAboutShowsDisclaimer() throws {
        app.tabBars.buttons["tab.profile"].tap()
        app.buttons["profile.settings"].tap()
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

    @MainActor
    func testFlightDetailShowsDisclaimer() throws {
        app.buttons["home.row.kpao-kmry-20261004"].tap()
        let element = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier == 'detail.disclaimer' AND label CONTAINS %@", disclaimer))
            .firstMatch
        XCTAssertTrue(element.waitForExistence(timeout: 5))
        XCTAssertTrue(element.label.contains("Not for navigation"), element.label)
    }
}
