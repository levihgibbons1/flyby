import Testing
@testable import Flyby

struct FlybyTests {
    @Test func appModuleLoads() {
        // Scaffold check: the test target links against the app module.
        _ = RootView()
    }
}
