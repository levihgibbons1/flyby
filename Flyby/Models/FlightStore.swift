import Foundation
import Observation

/// In-memory flight journal for Sprint 1 (mock data only, nothing persisted).
@Observable
final class FlightStore {
    /// Newest first.
    private(set) var flights: [Flight]

    init(flights: [Flight] = MockFlights.all) {
        self.flights = flights.sorted { $0.date > $1.date }
    }

    /// Adds a flight in date order. A new flight goes ahead of older flights on
    /// the same date, so a just-logged flight shows first.
    func add(_ flight: Flight) {
        let index = flights.firstIndex { $0.date <= flight.date } ?? flights.endIndex
        flights.insert(flight, at: index)
    }

    func flight(id: Flight.ID) -> Flight? {
        flights.first { $0.id == id }
    }

    /// Flights grouped by calendar month, newest month first.
    func monthSections(calendar: Calendar = .current) -> [MonthSection] {
        let grouped = Dictionary(grouping: flights) {
            calendar.dateInterval(of: .month, for: $0.date)?.start ?? $0.date
        }
        return grouped.keys.sorted(by: >).map { month in
            MonthSection(month: month, flights: grouped[month] ?? [])
        }
    }

    /// Totals for one calendar year, or all time when `year` is nil.
    func totals(year: Int? = nil, calendar: Calendar = .current) -> FlightTotals {
        let selected = flights.filter { flight in
            year.map { calendar.component(.year, from: flight.date) == $0 } ?? true
        }
        return FlightTotals(flights: selected)
    }

    /// Airports flown from or to, most visited first.
    var visitedAirports: [(airport: Airport, visits: Int)] {
        var visits: [Airport: Int] = [:]
        for flight in flights {
            visits[flight.departure, default: 0] += 1
            if flight.arrival != flight.departure {
                visits[flight.arrival, default: 0] += 1
            }
        }
        return visits.map { (airport: $0.key, visits: $0.value) }
            .sorted { ($0.visits, $1.airport.icao) > ($1.visits, $0.airport.icao) }
    }

    /// Aircraft flown, most recent first, as "Cirrus SR22 · N482CD".
    var aircraft: [String] {
        var seen = Set<String>()
        return flights.compactMap { flight in
            let name = [flight.aircraftType, flight.tailNumber].filter { !$0.isEmpty }.joined(separator: " · ")
            return seen.insert(name).inserted ? name : nil
        }
    }
}

struct MonthSection: Identifiable {
    let month: Date
    let flights: [Flight]
    var id: Date { month }
}

struct FlightTotals: Equatable {
    var count: Int
    var flightTime: TimeInterval
    var airports: Int
    var distanceNM: Double

    init(flights: [Flight]) {
        count = flights.count
        flightTime = flights.reduce(0) { $0 + $1.flightDuration }
        airports = Set(flights.flatMap { [$0.departure.icao, $0.arrival.icao] }).count
        distanceNM = flights.reduce(0) { $0 + $1.distanceNM }
    }
}
