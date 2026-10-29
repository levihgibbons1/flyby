import CoreLocation
import Foundation
import Testing
@testable import Flyby

struct FlightModelTests {
    private func makeFlight(date: Date = .now) -> Flight {
        Flight(date: date, aircraftType: "Cessna 172S",
               departure: MockAirports.kpao, arrival: MockAirports.kmry, flightDuration: 44 * 60)
    }

    @Test func newFlightDefaultsToPrivate() {
        #expect(makeFlight().visibility == .private)
        #expect(FlightVisibility.default == .private)
    }

    @Test func routeIsSpokenWithToNotArrow() {
        let flight = makeFlight()
        #expect(flight.routeTitle == "KPAO → KMRY")
        #expect(flight.routeSpokenTitle == "KPAO to KMRY")
        #expect(!flight.accessibilitySummary.contains("→"))
        #expect(flight.accessibilitySummary.contains("Palo Alto to Monterey Regional"))
        #expect(flight.accessibilitySummary.contains("Visibility: Private"))
    }

    @Test func distanceFallsBackToGreatCircleWithoutTrack() {
        // KPAO to KMRY is about 57 nm direct.
        #expect((50...65).contains(makeFlight().distanceNM))
    }

    @Test func durationFormats() {
        #expect(FlightFormat.duration(58 * 60) == "0:58")
        #expect(FlightFormat.duration(72 * 60) == "1:12")
        #expect(FlightFormat.duration(-5) == "0:00")
    }
}

struct MockDataTests {
    @Test func includesA500PointTrack() {
        #expect(MockFlights.all.contains { $0.track.count >= 500 })
    }

    @Test func includesAFlightWithoutTrack() {
        #expect(MockFlights.all.contains { $0.track.isEmpty })
    }

    @Test func tracksStartAndEndOnTheirAirports() {
        for flight in MockFlights.all {
            guard let first = flight.track.first, let last = flight.track.last else { continue }
            #expect(Geo.distanceNM(first.coordinate, flight.departure.coordinate) < 0.1, "\(flight.id)")
            #expect(Geo.distanceNM(last.coordinate, flight.arrival.coordinate) < 0.1, "\(flight.id)")
        }
    }

    @Test func trackPointsAreValid() {
        for point in MockFlights.all.flatMap(\.track) {
            #expect(CLLocationCoordinate2DIsValid(point.coordinate))
            #expect(point.altitudeFeet.map { $0 >= 0 } ?? true)
        }
    }

    @Test func everyMockFlightUsesListedAirports() {
        for flight in MockFlights.all {
            #expect(MockAirports.airport(icao: flight.departure.icao) == flight.departure)
            #expect(MockAirports.airport(icao: flight.arrival.icao) == flight.arrival)
        }
    }

    @Test func airportLookupIgnoresCaseAndSpaces() {
        #expect(MockAirports.airport(icao: " ksql ") == MockAirports.ksql)
        #expect(MockAirports.airport(icao: "KXYZ") == nil)
    }

    @Test func mockIDsAreUnique() {
        #expect(Set(MockFlights.all.map(\.id)).count == MockFlights.all.count)
    }
}

struct FlightStoreTests {
    @Test func flightsAreNewestFirst() {
        let store = FlightStore()
        #expect(store.flights.map(\.date) == store.flights.map(\.date).sorted(by: >))
    }

    @Test func addedFlightShowsFirst() {
        let store = FlightStore()
        let flight = Flight(date: .now, aircraftType: "Piper Archer",
                            departure: MockAirports.ksql, arrival: MockAirports.khaf, flightDuration: 1_800)
        store.add(flight)
        #expect(store.flights.first?.id == flight.id)
    }

    @Test func totalsCountFlightsTimeAndAirports() {
        let store = FlightStore()
        let totals = store.totals()
        #expect(totals.count == MockFlights.all.count)
        #expect(totals.flightTime == MockFlights.all.reduce(0) { $0 + $1.flightDuration })
        #expect(totals.airports == 6)  // KPAO KMRY KSQL KTVL KHAF KSBA
        #expect(store.totals(year: 1999).count == 0)
    }

    @Test func monthSectionsGroupByMonthNewestFirst() {
        let sections = FlightStore().monthSections()
        #expect(sections.count == 3)  // Oct, Sep, Aug 2026
        #expect(sections.map(\.month) == sections.map(\.month).sorted(by: >))
    }
}

struct PrivacySettingsTests {
    @Test func defaultsAreMostPrivate() {
        let profile = ProfileStore()
        #expect(profile.hideHomeAirport == true)
        #expect(profile.defaultVisibility == .private)
        #expect(profile.defaultTrimNM == 1.0)
        #expect(profile.homeAirport == MockAirports.ksql)
    }
}
