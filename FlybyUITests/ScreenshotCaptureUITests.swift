import XCTest

/// Captures screenshots and the VoiceOver accessibility tree of each screen
/// for PR review. Skipped unless `FLYBY_SCREENSHOT_DIR` is set, e.g.
/// `TEST_RUNNER_FLYBY_SCREENSHOT_DIR=/tmp/shots xcodebuild test …`.
/// Appearance and text size come from the simulator (`xcrun simctl ui`).
final class ScreenshotCaptureUITests: XCTestCase {
    @MainActor
    func testCaptureScreens() throws {
        let environment = ProcessInfo.processInfo.environment
        guard let directory = environment["FLYBY_SCREENSHOT_DIR"] else {
            throw XCTSkip("Set FLYBY_SCREENSHOT_DIR to capture screenshots")
        }
        let prefix = environment["FLYBY_SCREENSHOT_PREFIX"] ?? "screen"
        let outputURL = URL(fileURLWithPath: directory, isDirectory: true)
        try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["tab.home"].waitForExistence(timeout: 5))

        var accessibilityTree = ""
        func capture(_ name: String) throws {
            sleep(1)
            let png = XCUIScreen.main.screenshot().pngRepresentation
            try png.write(to: outputURL.appendingPathComponent("\(prefix)-\(name).png"))
            accessibilityTree += "===== \(name)\n\(app.debugDescription)\n\n"
        }

        try capture("1-home")
        app.swipeUp()
        app.swipeUp()
        try capture("2-home-bottom")
        // Scrolling down minimizes the iOS 26 tab bar; scroll back to restore it.
        app.swipeDown()
        app.swipeDown()
        app.tabBars.buttons["tab.explore"].tap()
        try capture("3-explore")
        app.tabBars.buttons["tab.flights"].tap()
        try capture("4-flights")
        app.tabBars.buttons["tab.profile"].tap()
        try capture("5-profile")
        app.tabBars.buttons["tab.record"].tap()
        XCTAssertTrue(app.navigationBars["Log a Flight"].waitForExistence(timeout: 3))
        try capture("6-log-flight")

        try accessibilityTree.write(
            to: outputURL.appendingPathComponent("\(prefix)-accessibility.txt"),
            atomically: true, encoding: .utf8)
    }
}
