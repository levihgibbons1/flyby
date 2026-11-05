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

        let disclaimer = app.descendants(matching: .any)["detail.disclaimer"]
        XCTAssertTrue(disclaimer.waitForExistence(timeout: 5))
        XCTAssertTrue(disclaimer.label.contains("Personal journal · Not for navigation"), disclaimer.label)

        let map = app.descendants(matching: .any)["detail.map"]
        XCTAssertTrue(map.waitForExistence(timeout: 5))
        XCTAssertTrue(map.label.contains("Palo Alto to Monterey Regional"), map.label)
        XCTAssertTrue(map.label.contains("nautical miles"), map.label)

        let visibility = app.descendants(matching: .any)["detail.visibility"]
        XCTAssertTrue(visibility.waitForExistence(timeout: 3))
        XCTAssertTrue(visibility.label.contains("Private"), visibility.label)

        let duration = app.descendants(matching: .any)["detail.stat.duration"]
        reveal(duration)
        XCTAssertTrue(duration.waitForExistence(timeout: 3))
        XCTAssertTrue(app.descendants(matching: .any)["detail.stat.distance"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["detail.stat.maxAlt"].exists)
        let aircraft = app.descendants(matching: .any)["detail.stat.aircraft"]
        XCTAssertTrue(aircraft.exists)
        let aircraftValue = aircraft.value as? String ?? ""
        XCTAssertTrue(aircraft.label.contains("Cessna 172S") || aircraftValue.contains("Cessna 172S"),
                      "\(aircraft.label) \(aircraftValue)")

        let tail = app.descendants(matching: .any)["detail.tail"]
        XCTAssertTrue(tail.label.contains("N739PA") || (tail.value as? String)?.contains("N739PA") == true,
                      tail.label)

        XCTAssertFalse(app.descendants(matching: .any)["detail.approximate"].exists)
        XCTAssertFalse(app.alerts.firstMatch.waitForExistence(timeout: 1))

        let notes = app.descendants(matching: .any)["detail.notes"]
        reveal(notes)
        XCTAssertTrue(notes.waitForExistence(timeout: 3))
        XCTAssertTrue(notes.label.contains("Santa Cruz"), notes.label)

        let photo = app.descendants(matching: .any)["detail.photo.kpao-kmry-coast"]
        reveal(photo)
        XCTAssertTrue(photo.waitForExistence(timeout: 3))
        XCTAssertTrue(photo.label.contains("Photo 1 of 3"), photo.label)
    }

    @MainActor
    func testHomeRowShowsApproximateRoute() throws {
        app.buttons["home.row.khaf-ksql-20260907"].tap()
        XCTAssertTrue(app.navigationBars["KHAF → KSQL"].waitForExistence(timeout: 5))

        let approximate = app.descendants(matching: .any)["detail.approximate"]
        XCTAssertTrue(approximate.waitForExistence(timeout: 5))
        XCTAssertEqual(approximate.label, "Approximate route")

        let map = app.descendants(matching: .any)["detail.map"]
        XCTAssertTrue(map.waitForExistence(timeout: 5))
        XCTAssertTrue(map.label.contains("Approximate route, not the flown track"), map.label)
        XCTAssertTrue(app.descendants(matching: .any)["detail.disclaimer"].exists)
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
        let map = app.descendants(matching: .any)["detail.map"]
        XCTAssertTrue(map.waitForExistence(timeout: 5))
        XCTAssertTrue(map.label.contains("San Carlos to Lake Tahoe"), map.label)
        let visibility = app.descendants(matching: .any)["detail.visibility"]
        XCTAssertTrue(visibility.label.contains("Followers"), visibility.label)
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
