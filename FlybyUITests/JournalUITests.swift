import XCTest

/// Mock journal: rows, privacy defaults and the empty state.
final class JournalUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    private func launch(_ arguments: [String] = []) {
        app.launchArguments = arguments
        app.launch()
        app.requireTabBar()
    }

    @MainActor
    func testFlightRowsReadRouteWithToAndVisibility() throws {
        launch()
        app.tabBars.buttons["tab.flights"].tap()
        let row = app.buttons["flights.row.kpao-kmry-20261004"]
        XCTAssertTrue(row.waitForExistence(timeout: 3))
        XCTAssertTrue(row.label.contains("Palo Alto to Monterey Regional"), row.label)
        XCTAssertFalse(row.label.contains("→"), row.label)
        XCTAssertTrue(row.label.contains("Visibility: Private"), row.label)
    }

    @MainActor
    func testHideHomeAirportIsOnByDefault() throws {
        launch()
        app.tabBars.buttons["tab.profile"].tap()
        app.buttons["profile.settings"].tap()
        let toggle = app.switches["settings.hideHome"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 3))
        XCTAssertEqual(toggle.value as? String, "1")
    }

    @MainActor
    func testHomeOpensFlightDetail() throws {
        launch()
        app.buttons["home.row.kpao-kmry-20261004"].tap()
        XCTAssertTrue(app.navigationBars["KPAO → KMRY"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testEmptyJournalShowsEmptyStateThatOpensLogSheet() throws {
        launch(["-FlybyEmptyJournal"])
        XCTAssertTrue(app.otherElements["empty.state"].exists || app.staticTexts["Log your first flight"].exists)
        app.buttons["empty.action"].tap()
        XCTAssertTrue(app.navigationBars["Log a Flight"].waitForExistence(timeout: 3))
    }
}
