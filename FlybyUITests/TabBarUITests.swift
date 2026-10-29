import XCTest

final class TabBarUITests: XCTestCase {
    private let tabIDs = ["tab.home", "tab.explore", "tab.record", "tab.flights", "tab.profile"]
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        let home = app.tabBars.buttons["tab.home"]
        if !home.waitForExistence(timeout: 8) {
            let summary = app.tabBars.buttons.allElementsBoundByIndex
                .map { "\($0.label)#\($0.identifier)" }
                .joined(separator: ", ")
            XCTFail("Tab bar identifiers were not installed (\(summary))")
        }
    }

    @MainActor
    func testFiveTabsInOrderWithIdentifiersAndLabels() throws {
        let tabBar = app.tabBars.firstMatch

        let buttons = tabBar.buttons.allElementsBoundByIndex
        XCTAssertEqual(buttons.map(\.identifier), tabIDs)
        XCTAssertEqual(buttons.map(\.label), ["Home", "Explore", "Record", "Flights", "Profile"])
        XCTAssertTrue(tabBar.buttons["tab.home"].isSelected)
    }

    @MainActor
    func testEachDestinationTabIsSelectable() throws {
        for (id, title) in [("tab.explore", "Explore"), ("tab.flights", "Flights"),
                            ("tab.profile", "Profile"), ("tab.home", "Home")] {
            app.tabBars.buttons[id].tap()
            XCTAssertTrue(app.tabBars.buttons[id].isSelected, id)
            XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 3), title)
        }
    }

    @MainActor
    func testRecordPresentsLogSheetAndKeepsPreviousTab() throws {
        app.tabBars.buttons["tab.flights"].tap()
        app.tabBars.buttons["tab.record"].tap()

        XCTAssertTrue(app.navigationBars["Log a Flight"].waitForExistence(timeout: 3))
        app.buttons["log.cancel"].tap()

        XCTAssertTrue(app.navigationBars["Flights"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.tabBars.buttons["tab.flights"].isSelected)
        XCTAssertFalse(app.tabBars.buttons["tab.record"].isSelected)
    }

    @MainActor
    func testNavigationStateSurvivesTabSwitch() throws {
        app.tabBars.buttons["tab.flights"].tap()
        app.buttons["flights.row.kpao-kmry-20261004"].tap()
        XCTAssertTrue(app.navigationBars["KPAO → KMRY"].waitForExistence(timeout: 3))

        app.tabBars.buttons["tab.home"].tap()
        app.tabBars.buttons["tab.flights"].tap()

        XCTAssertTrue(app.navigationBars["KPAO → KMRY"].waitForExistence(timeout: 3))
    }
}
