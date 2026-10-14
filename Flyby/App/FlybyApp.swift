import SwiftUI

@main
struct FlybyApp: App {
    @State private var flightStore = FlightStore(flights: FlybyApp.initialFlights)
    @State private var profileStore = ProfileStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(flightStore)
                .environment(profileStore)
        }
    }

    /// UI tests pass `-FlybyEmptyJournal` to start with no flights.
    private static var initialFlights: [Flight] {
        ProcessInfo.processInfo.arguments.contains("-FlybyEmptyJournal") ? [] : MockFlights.all
    }
}
