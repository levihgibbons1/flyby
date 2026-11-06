import XCTest

/// Manual logging: Private by default, inline errors, and a saved flight
/// that shows on Home, Flights, and Flight Detail.
final class LogFlightUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        app.requireTabBar()
    }

    @MainActor
    func testLogFormDefaultsToPrivateAndResets() throws {
        openLog()
        let privateOption = requireButton("log.visibility.private")
        XCTAssertTrue(privateOption.isSelected, privateOption.label)
        XCTAssertTrue(privateOption.label.contains("Private"), privateOption.label)
        XCTAssertFalse(requireButton("log.visibility.followers").isSelected)
        let publicOption = requireButton("log.visibility.public")
        XCTAssertFalse(publicOption.isSelected)

        publicOption.tap()
        XCTAssertTrue(publicOption.isSelected)

        app.buttons["log.cancel"].tap()
        let alert = app.alerts["Discard this flight?"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3))
        alert.buttons["Discard"].tap()
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))

        openLog()
        let reopened = requireButton("log.visibility.private")
        XCTAssertTrue(reopened.isSelected, "Opening the form again should select Private")
        XCTAssertFalse(requireButton("log.visibility.public").isSelected)
    }

    @MainActor
    func testUnknownAirportShowsTextError() throws {
        openLog()
        type("XXXX", into: "log.field.dep")
        let error = app.descendants(matching: .any)["log.field.dep.error"]
        XCTAssertTrue(error.waitForExistence(timeout: 3))
        XCTAssertTrue(error.label.contains("XXXX"), error.label)
        XCTAssertTrue(error.label.contains("isn't in the airport list"), error.label)

        let save = app.buttons["log.save"]
        if save.waitForExistence(timeout: 2) {
            XCTAssertFalse(save.isEnabled)
        }
    }

    @MainActor
    func testCancelAsksBeforeDiscardingEdits() throws {
        openLog()
        type("Cessna", into: "log.field.aircraft")
        app.buttons["log.cancel"].tap()

        let alert = app.alerts["Discard this flight?"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3))
        alert.buttons["Keep Editing"].tap()
        XCTAssertTrue(app.navigationBars["Log a Flight"].waitForExistence(timeout: 3))
        let aircraft = app.textFields["log.field.aircraft"]
        XCTAssertTrue(aircraft.waitForExistence(timeout: 3))
        XCTAssertEqual(aircraft.value as? String, "Cessna")

        app.buttons["log.cancel"].tap()
        XCTAssertTrue(alert.waitForExistence(timeout: 3))
        alert.buttons["Discard"].tap()
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSavedFlightShowsOnHomeFlightsDetailAndProfile() throws {
        let before = profileFlightCount()
        logSampleFlight()

        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
        XCTAssertEqual(waitForProfileFlightCount(before + 1), before + 1)

        app.tabBars.buttons["tab.home"].tap()
        let home = flightRow(prefix: "home.row.")
        XCTAssertTrue(home.waitForExistence(timeout: 5), "Home did not show the logged flight")

        app.tabBars.buttons["tab.flights"].tap()
        let row = flightRow(prefix: "flights.row.")
        XCTAssertTrue(row.waitForExistence(timeout: 5), "Flights did not show the logged flight")
        row.tap()

        XCTAssertTrue(app.navigationBars["KSQL → KHAF"].waitForExistence(timeout: 5))
        let visibility = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier == 'detail.visibility' AND label CONTAINS 'Private'")
        ).firstMatch
        XCTAssertTrue(visibility.waitForExistence(timeout: 3))
        XCTAssertTrue(app.descendants(matching: .any)["detail.approximate"].waitForExistence(timeout: 3))
    }

    @MainActor
    private func logSampleFlight() {
        openLog()
        type("Cessna 172", into: "log.field.aircraft")
        type("KSQL", into: "log.field.dep")
        type("KHAF", into: "log.field.arr")
        type("30", into: "log.field.durationMinutes")

        let save = app.buttons["log.save"]
        reveal(save)
        XCTAssertTrue(save.waitForExistence(timeout: 3))
        XCTAssertTrue(save.isEnabled, "Save stayed dimmed after a complete entry")
        save.tap()
    }

    private func flightRow(prefix: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(
            format: "identifier BEGINSWITH %@ AND label CONTAINS 'San Carlos to Half Moon Bay' AND label CONTAINS 'Visibility: Private'",
            prefix
        )).firstMatch
    }

    /// Profile's flight total updates as soon as the sheet closes. Wait out the
    /// dismiss animation before reading it.
    @MainActor
    private func waitForProfileFlightCount(_ expected: Int) -> Int {
        app.tabBars.buttons["tab.profile"].tap()
        let stat = app.descendants(matching: .any)["profile.stat.flights"]
        XCTAssertTrue(stat.waitForExistence(timeout: 3))
        let predicate = NSPredicate(format: "value == %@ OR label == %@", "\(expected)", "\(expected)")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: stat)
        _ = XCTWaiter().wait(for: [expectation], timeout: 5)
        return profileFlightCount()
    }

    @MainActor
    private func profileFlightCount() -> Int {
        app.tabBars.buttons["tab.profile"].tap()
        let stat = app.descendants(matching: .any)["profile.stat.flights"]
        XCTAssertTrue(stat.waitForExistence(timeout: 3))
        if let text = stat.value as? String, let count = Int(text) { return count }
        let digits = "\(stat.label) \(stat.value ?? "")".split(whereSeparator: { !$0.isNumber })
        if let count = digits.compactMap({ Int($0) }).last { return count }
        XCTFail("Profile flight count was \(stat.label) / \(String(describing: stat.value))")
        return -1
    }

    /// iOS 26 only builds a list row once it is on screen, and reading
    /// `isSelected` on a missing button fails the test outright.
    @MainActor
    private func requireButton(_ identifier: String) -> XCUIElement {
        let button = app.buttons[identifier]
        reveal(button)
        XCTAssertTrue(button.waitForExistence(timeout: 3), identifier)
        return button
    }

    @MainActor
    private func openLog() {
        app.tabBars.buttons["tab.record"].tap()
        XCTAssertTrue(app.navigationBars["Log a Flight"].waitForExistence(timeout: 3))
    }

    @MainActor
    private func type(_ text: String, into identifier: String) {
        let field = app.textFields[identifier]
        reveal(field)
        XCTAssertTrue(field.waitForExistence(timeout: 3), identifier)
        field.tap()
        field.typeText(text)
        dismissKeyboard()
    }

    @MainActor
    private func dismissKeyboard() {
        let done = app.buttons["log.keyboard.done"]
        if done.waitForExistence(timeout: 2), done.isHittable {
            done.tap()
            return
        }
        let returnKey = app.keyboards.buttons["Return"]
        if returnKey.exists { returnKey.tap() }
    }

    /// Short drag inside the sheet, so the list moves and the sheet stays up.
    @MainActor
    private func reveal(_ element: XCUIElement) {
        if element.exists && element.isHittable { return }
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.72))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.38))
        for _ in 0..<8 {
            if element.exists && element.isHittable { return }
            start.press(forDuration: 0.05, thenDragTo: end)
        }
    }
}
