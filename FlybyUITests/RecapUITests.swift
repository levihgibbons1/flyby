import XCTest

/// Share Recap opens a preview. The image is not saved here: Save asks for Photos,
/// and these tests never tap it.
final class RecapUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        app.requireTabBar()
    }

    @MainActor
    func testShareRecapShowsPreviewWithPrivacyTogglesOn() throws {
        app.tabBars.buttons["tab.flights"].tap()
        let row = app.buttons["flights.row.ksql-ktvl-20260919"]
        XCTAssertTrue(reveal(row), "KSQL to KTVL was not in the logbook")
        row.tap()

        XCTAssertTrue(app.navigationBars["KSQL → KTVL"].waitForExistence(timeout: 5))
        let share = app.descendants(matching: .any)["detail.share"]
        XCTAssertTrue(share.waitForExistence(timeout: 3))
        share.tap()

        XCTAssertTrue(app.navigationBars["Share Recap"].waitForExistence(timeout: 5))
        let route = app.descendants(matching: .any)["recap.route"]
        XCTAssertTrue(route.waitForExistence(timeout: 5), "Route was not in the recap")
        XCTAssertTrue(app.descendants(matching: .any)["recap.preview"].waitForExistence(timeout: 3))

        let hide = app.switches["recap.toggle.hideHome"]
        let trim = app.switches["recap.toggle.trim"]
        XCTAssertTrue(reveal(hide))
        XCTAssertTrue(trim.waitForExistence(timeout: 3))
        XCTAssertEqual(hide.value as? String, "1")
        XCTAssertEqual(trim.value as? String, "1")

        XCTAssertTrue(copy(of: "recap.disclaimer").contains("Not for navigation"))
        XCTAssertTrue(copy(of: "recap.aircraft").contains("Cirrus SR22"))
        XCTAssertTrue(copy(of: "recap.brand").contains("Flyby"))
        XCTAssertTrue(copy(of: "recap.shareOnly").contains("this share only"))
        XCTAssertTrue(app.descendants(matching: .any)["recap.stat.duration"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["recap.homeNote"].exists)

        let hidden = copy(of: "recap.route") + "\n" + copy(of: "recap.homeNote") + "\n" + copy(of: "recap.aircraft")
        XCTAssertTrue(hidden.localizedCaseInsensitiveContains("bay area"), hidden)
        XCTAssertFalse(hidden.localizedCaseInsensitiveContains("ksql"), hidden)
        XCTAssertFalse(hidden.localizedCaseInsensitiveContains("san carlos"), hidden)

        hide.tap()
        XCTAssertTrue(waitUntilRouteShowsField(), copy(of: "recap.route"))

        hide.tap()
        XCTAssertTrue(waitUntilRouteHidesHome())
        let hiddenAgain = copy(of: "recap.route")
        XCTAssertFalse(hiddenAgain.localizedCaseInsensitiveContains("ksql"), hiddenAgain)
        XCTAssertFalse(hiddenAgain.localizedCaseInsensitiveContains("san carlos"), hiddenAgain)

        app.buttons["recap.share"].tap()
        XCTAssertTrue(waitForShareSheet(), shareSheetFailure())
    }

    private func copy(of identifier: String) -> String {
        let element = app.descendants(matching: .any)[identifier]
        let value = element.value as? String ?? ""
        return "\(element.label) \(value)"
    }

    /// The field is showing when either its name or its ICAO is back on the route.
    private func waitUntilRouteShowsField() -> Bool {
        let deadline = Date().addingTimeInterval(3)
        while Date() < deadline {
            let text = copy(of: "recap.route")
            if text.localizedCaseInsensitiveContains("san carlos") || text.localizedCaseInsensitiveContains("ksql") {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        return false
    }

    private func waitUntilRouteHidesHome() -> Bool {
        let deadline = Date().addingTimeInterval(3)
        while Date() < deadline {
            let text = copy(of: "recap.route")
            if !text.localizedCaseInsensitiveContains("ksql"),
               !text.localizedCaseInsensitiveContains("san carlos"),
               text.localizedCaseInsensitiveContains("bay area") {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        return false
    }

    private func shareSheetIsVisible() -> Bool {
        if app.otherElements["ActivityListView"].exists { return true }
        if app.otherElements["recap.shareSheet"].exists { return true }
        let names = ["Copy", "Save to Files", "Add to Files", "Messages", "Mail", "AirDrop"]
        for name in names {
            if app.buttons[name].exists || app.staticTexts[name].exists || app.cells[name].exists {
                return true
            }
        }
        return false
    }

    private func waitForShareSheet() -> Bool {
        let deadline = Date().addingTimeInterval(8)
        while Date() < deadline {
            if shareSheetIsVisible() { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        return shareSheetIsVisible()
    }

    private func shareSheetFailure() -> String {
        let error = app.descendants(matching: .any)["recap.error"]
        let buttons = app.buttons.allElementsBoundByIndex.prefix(30).map(\.label).joined(separator: ", ")
        let errorText = error.exists ? error.label : "none"
        return "Share sheet did not appear. error=\(errorText) buttons=\(buttons)"
    }

    @discardableResult
    private func reveal(_ element: XCUIElement) -> Bool {
        if element.waitForExistence(timeout: 2), element.isHittable { return true }
        if element.exists, element.isHittable { return true }
        for _ in 0..<4 {
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.72))
            let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.42))
            start.press(forDuration: 0.01, thenDragTo: end)
            if element.exists, element.isHittable { return true }
        }
        return element.exists && element.isHittable
    }
}
