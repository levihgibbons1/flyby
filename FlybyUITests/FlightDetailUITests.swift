import XCTest

/// Flight Detail, opened from Home and Flights. Display only: route, stats,
/// photos, and the not-for-navigation line. No location prompt.
final class FlightDetailUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        app.requireTabBar()
    }

    @MainActor
    func testHomeRowShowsTrackedFlight() throws {
        app.buttons["home.row.kpao-kmry-20261004"].tap()
        XCTAssertTrue(app.navigationBars["KPAO → KMRY"].waitForExistence(timeout: 5))

        let disclaimer = labeled("detail.disclaimer", containing: "Personal journal · Not for navigation")
        XCTAssertTrue(disclaimer.waitForExistence(timeout: 5))

        let map = labeled("detail.map", containing: "Palo Alto to Monterey Regional")
        XCTAssertTrue(map.waitForExistence(timeout: 5))
        XCTAssertTrue(map.label.contains("nautical miles"), map.label)

        let visibility = labeled("detail.visibility", containing: "Private")
        XCTAssertTrue(visibility.waitForExistence(timeout: 3))

        let duration = app.descendants(matching: .any).matching(identifier: "detail.stat.duration").firstMatch
        reveal(duration)
        XCTAssertTrue(duration.waitForExistence(timeout: 3))
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "detail.stat.distance").firstMatch.exists)
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "detail.stat.maxAlt").firstMatch.exists)
        let aircraft = app.descendants(matching: .any).matching(identifier: "detail.stat.aircraft").firstMatch
        XCTAssertTrue(aircraft.waitForExistence(timeout: 3))
        let aircraftValue = aircraft.value as? String ?? ""
        XCTAssertTrue(aircraft.label.contains("Cessna 172S") || aircraftValue.contains("Cessna 172S"),
                      "\(aircraft.label) \(aircraftValue)")

        let tail = app.descendants(matching: .any).matching(identifier: "detail.tail").firstMatch
        XCTAssertTrue(tail.waitForExistence(timeout: 3))
        let tailValue = tail.value as? String ?? ""
        XCTAssertTrue(tail.label.contains("N739PA") || tailValue.contains("N739PA"), "\(tail.label) \(tailValue)")

        XCTAssertFalse(app.descendants(matching: .any).matching(identifier: "detail.approximate").firstMatch.exists)
        XCTAssertFalse(app.alerts.firstMatch.waitForExistence(timeout: 1))

        let notes = labeled("detail.notes", containing: "Santa Cruz")
        reveal(notes)
        XCTAssertTrue(notes.waitForExistence(timeout: 3))

        let photo = labeled("detail.photo.kpao-kmry-coast", containing: "Photo 1 of 3")
        reveal(photo)
        XCTAssertTrue(photo.waitForExistence(timeout: 3))
    }

    /// One match whose label or value contains `snippet`, so a duplicate icon
    /// (the disclaimer image is also `detail.disclaimer`) does not fail the query.
    private func labeled(_ identifier: String, containing snippet: String) -> XCUIElement {
        let predicate = NSPredicate(format: "identifier == %@ AND (label CONTAINS %@ OR value CONTAINS %@)",
                                    identifier, snippet, snippet)
        return app.descendants(matching: .any).matching(predicate).firstMatch
    }

    /// iOS 26 does not build off-screen list rows until the list moves.
    private func scrollUntilExists(_ element: XCUIElement) -> Bool {
        if element.waitForExistence(timeout: 1) { return true }
        for _ in 0..<5 {
            app.swipeUp()
            if element.exists { return true }
        }
        return false
    }

    @MainActor
    func testHomeRowShowsApproximateRoute() throws {
        // iOS 26's list only exposes the first Home row until the list scrolls.
        let home = app.buttons["home.row.khaf-ksql-20260907"]
        if !scrollUntilExists(home) {
            app.tabBars.buttons["tab.flights"].tap()
            let row = app.buttons["flights.row.khaf-ksql-20260907"]
            XCTAssertTrue(scrollUntilExists(row), "Approximate flight was not in Home or Flights")
            row.tap()
        } else {
            home.tap()
        }
        XCTAssertTrue(app.navigationBars["KHAF → KSQL"].waitForExistence(timeout: 5))

        let approximate = app.descendants(matching: .any).matching(identifier: "detail.approximate").firstMatch
        XCTAssertTrue(approximate.waitForExistence(timeout: 5))
        XCTAssertEqual(approximate.label, "Approximate route")

        let map = labeled("detail.map", containing: "Approximate route, not the flown track")
        XCTAssertTrue(map.waitForExistence(timeout: 5))
        XCTAssertTrue(labeled("detail.disclaimer", containing: "Not for navigation").waitForExistence(timeout: 3))
        XCTAssertFalse(app.alerts.firstMatch.exists)
    }

    @MainActor
    func testFlightsRowOpensLongTrack() throws {
        app.tabBars.buttons["tab.flights"].tap()
        let row = app.buttons["flights.row.ksql-ktvl-20260919"]
        reveal(row)
        XCTAssertTrue(row.waitForExistence(timeout: 3))
        row.tap()

        XCTAssertTrue(app.navigationBars["KSQL → KTVL"].waitForExistence(timeout: 5))
        let map = labeled("detail.map", containing: "San Carlos to Lake Tahoe")
        XCTAssertTrue(map.waitForExistence(timeout: 5))
        let visibility = labeled("detail.visibility", containing: "Followers")
        XCTAssertTrue(visibility.waitForExistence(timeout: 3))
        XCTAssertFalse(app.alerts.firstMatch.exists)
    }

    /// The map sits above the scrolling content, so drag the lower part of the screen.
    private func reveal(_ element: XCUIElement) {
        var attempts = 0
        while !element.exists && attempts < 4 {
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.72))
            let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.38))
            start.press(forDuration: 0.01, thenDragTo: end)
            attempts += 1
        }
    }
}
