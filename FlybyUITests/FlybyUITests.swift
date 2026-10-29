import XCTest

extension XCUIApplication {
    /// Fails with the tab buttons XCUITest actually sees, on one log line.
    func requireTabBar(file: StaticString = #filePath, line: UInt = #line) {
        let home = tabBars.buttons["tab.home"]
        guard !home.waitForExistence(timeout: 8) else { return }
        let summary = tabBars.buttons.allElementsBoundByIndex
            .map { "\($0.label)#\($0.identifier)" }
            .joined(separator: ", ")
        XCTFail("Tab bar identifiers were not installed (\(summary))", file: file, line: line)
    }
}

final class FlybyUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
    }
}
