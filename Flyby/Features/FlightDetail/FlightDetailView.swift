import SwiftUI

/// Flight Detail. The map and recap arrive in #5 and #7.
struct FlightDetailView: View {
    let flight: Flight

    var body: some View {
        List {
            Section {
                FactRow("Date", value: flight.date.formatted(date: .long, time: .omitted))
                FactRow("Aircraft", value: flight.aircraftType)
                if !flight.tailNumber.isEmpty {
                    FactRow("Tail number", value: flight.tailNumber)
                }
                FactRow("Flight time", value: FlightFormat.duration(flight.flightDuration))
                FactRow("Distance", value: "\(FlightFormat.distance(flight.distanceNM)) nm")
                FactRow("Visibility", value: flight.visibility.title)
            }
            if !flight.notes.isEmpty {
                Section("Notes") { Text(flight.notes) }
            }
        }
        .navigationTitle(flight.routeTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
