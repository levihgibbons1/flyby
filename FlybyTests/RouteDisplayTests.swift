import CoreLocation
import Foundation
import Testing
@testable import Flyby

struct RouteDisplayTests {
    @Test func recordedFlightDrawsItsTrack() {
        let flight = MockFlights.kpaoKmry
        let route = RouteDisplay(flight: flight)
        #expect(route.kind == .track)
        #expect(route.segments.count == 1)
        #expect(route.summary == "Route map, Palo Alto to Monterey Regional, \(FlightFormat.distance(flight.distanceNM)) nautical miles")
        #expect(route.departureCode == "KPAO")
        #expect(route.arrivalCode == "KMRY")
        expectEndpoints(route, near: flight)
        expectCameraFits(route)
    }

    @Test func longTrackIsBuiltOnceAndStaysWithinTheRecording() {
        let flight = MockFlights.ksqlKtvl
        #expect(flight.track.count >= 500)
        let first = RouteDisplay(flight: flight)
        let second = RouteDisplay(flight: flight)
        #expect(first == second)
        #expect(first.kind == .track)
        let drawn = first.segments.reduce(0) { $0 + $1.count }
        #expect(drawn >= 2)
        #expect(drawn <= flight.track.count)
        expectEndpoints(first, near: flight)
        expectCameraFits(first)
    }

    @Test func flightWithoutTrackUsesGreatCircle() {
        let flight = MockFlights.khafKsql
        #expect(flight.track.isEmpty)
        let route = RouteDisplay(flight: flight)
        #expect(route.kind == .approximate)
        #expect(route.summary.contains("Approximate route, not the flown track"))
        #expect(route.summary.contains("Half Moon Bay to San Carlos"))
        #expect(!route.segments.isEmpty)
        expectEndpoints(route, near: flight)
        expectCameraFits(route)
        // The sampled arc stays on the great circle, including its midpoint.
        let middle = Geo.interpolate(flight.departure.coordinate, flight.arrival.coordinate, fraction: 0.5)
        let drawn = route.segments.flatMap { $0 }
        #expect(drawn.contains { Geo.distanceNM($0.location, middle) < 5 })
    }

    @Test func straightTrackCollapsesToItsEndpoints() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let points = (0..<40).map { index in
            TrackPoint(latitude: 37, longitude: -122 + Double(index) * 0.01,
                       altitudeFeet: 1_000, timestamp: start.addingTimeInterval(Double(index) * 30))
        }
        let route = RouteDisplay(flight: flight(track: points, date: start))
        #expect(route.kind == .track)
        #expect(route.segments.flatMap { $0 }.count == 2)
    }

    @Test func spikeAndInvalidPointsAreDropped() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let points = [
            TrackPoint(latitude: .nan, longitude: -122, altitudeFeet: nil, timestamp: start),
            TrackPoint(latitude: 95, longitude: -122, altitudeFeet: nil, timestamp: start),
            TrackPoint(latitude: 10, longitude: -200, altitudeFeet: nil, timestamp: start),
            TrackPoint(latitude: 0, longitude: 0, altitudeFeet: nil, timestamp: start),
            TrackPoint(latitude: 36, longitude: -121, altitudeFeet: nil, timestamp: start.addingTimeInterval(3 * 86_400)),
            TrackPoint(latitude: 37.0, longitude: -122.0, altitudeFeet: 100, timestamp: start),
            TrackPoint(latitude: 50, longitude: -100, altitudeFeet: 100, timestamp: start.addingTimeInterval(5)),
            TrackPoint(latitude: 37.2, longitude: -121.8, altitudeFeet: 100, timestamp: start.addingTimeInterval(10)),
        ]
        let route = RouteDisplay(flight: flight(track: points, date: start))
        #expect(route.kind == .track)
        let drawn = route.segments.flatMap { $0 }
        #expect(drawn.count == 2)
        #expect(drawn.allSatisfy { $0.latitude < 40 })
        #expect(drawn.allSatisfy { $0.latitude != 0 || $0.longitude != 0 })
    }

    @Test func oneUsablePointFallsBackToApproximate() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let points = [TrackPoint(latitude: 37, longitude: -122, altitudeFeet: nil, timestamp: start)]
        let route = RouteDisplay(flight: flight(track: points, date: start))
        #expect(route.kind == .approximate)
        #expect(!route.segments.isEmpty)
    }

    @Test func sameAirportWithoutTrackIsUnavailable() {
        let airport = MockAirports.ksql
        let flight = Flight(date: .now, aircraftType: "Cessna 172S",
                            departure: airport, arrival: airport, flightDuration: 600)
        let route = RouteDisplay(flight: flight)
        #expect(route.kind == .unavailable)
        #expect(route.segments.isEmpty)
        #expect(route.camera == nil)
        #expect(route.departure == nil)
        #expect(route.summary == "Route unavailable")
    }

    @Test func antimeridianTrackSplitsAndFramesTheShortWay() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let points = [
            TrackPoint(latitude: 21, longitude: 170, altitudeFeet: 100, timestamp: start),
            TrackPoint(latitude: 22, longitude: -170, altitudeFeet: 100, timestamp: start.addingTimeInterval(600)),
        ]
        let route = RouteDisplay(flight: flight(track: points, date: start,
                                                departure: pacific(icao: "EAST", longitude: 170),
                                                arrival: pacific(icao: "WEST", longitude: -170)))
        #expect(route.kind == .track)
        #expect(route.segments.count == 2)
        #expect(route.segments.allSatisfy { segment in
            guard let first = segment.first, let last = segment.last else { return false }
            return abs(first.longitude - last.longitude) <= 180 && segment.count >= 2
        })
        let longitudes = route.segments.flatMap { $0.map(\.longitude) }
        #expect(longitudes.contains { $0 >= 170 })
        #expect(longitudes.contains { $0 <= -170 })
        let camera = route.camera
        #expect(camera != nil)
        if let camera {
            #expect(camera.longitudeDelta > 20)
            #expect(camera.longitudeDelta < 40)
            #expect(longitudeGap(camera.centerLongitude, 180) < 1)
        }
        expectCameraFits(route)
    }

    @Test func antimeridianWithoutTrackUsesTheShortGreatCircle() {
        let departure = pacific(icao: "EAST", longitude: 170)
        let arrival = pacific(icao: "WEST", longitude: -170)
        let flight = Flight(date: .now, aircraftType: "Cessna 172S",
                            departure: departure, arrival: arrival, flightDuration: 3_600)
        let route = RouteDisplay(flight: flight)
        #expect(route.kind == .approximate)
        #expect(route.segments.count == 2)
        let longitudes = route.segments.flatMap { $0.map(\.longitude) }
        #expect(longitudes.allSatisfy { abs($0) > 150 })
        if let camera = route.camera {
            #expect(camera.longitudeDelta < 40)
        }
        expectCameraFits(route)
    }

    @Test func mockFlightsHavePhotosAndAPrivateDefault() {
        #expect(MockFlights.all.allSatisfy { !$0.photos.isEmpty })
        #expect(MockFlights.kpaoKmry.visibility == .private)
        #expect(MockFlights.kpaoKmry.photos.contains { $0.caption.contains("Santa Cruz") })
    }

    private func flight(track: [TrackPoint], date: Date,
                        departure: Airport = MockAirports.kpao,
                        arrival: Airport = MockAirports.kmry) -> Flight {
        Flight(date: date, aircraftType: "Cessna 172S", departure: departure, arrival: arrival,
               flightDuration: 3_600, track: track, source: .recorded)
    }

    private func pacific(icao: String, longitude: Double) -> Airport {
        Airport(icao: icao, name: icao, region: "Pacific", latitude: 21.5, longitude: longitude)
    }

    private func expectEndpoints(_ route: RouteDisplay, near flight: Flight) {
        #expect(route.departure != nil)
        #expect(route.arrival != nil)
        guard let departure = route.departure, let arrival = route.arrival else { return }
        #expect(Geo.distanceNM(departure.location, flight.departure.coordinate) < 0.2)
        #expect(Geo.distanceNM(arrival.location, flight.arrival.coordinate) < 0.2)
    }

    private func expectCameraFits(_ route: RouteDisplay) {
        #expect(route.camera != nil)
        guard let camera = route.camera else { return }
        let points = route.segments.flatMap { $0 }
        #expect(!points.isEmpty)
        for point in points {
            #expect(abs(point.latitude - camera.centerLatitude) <= camera.latitudeDelta / 2 + 0.001)
            #expect(longitudeGap(point.longitude, camera.centerLongitude) <= camera.longitudeDelta / 2 + 0.001)
        }
    }

    private func longitudeGap(_ start: Double, _ end: Double) -> Double {
        let raw = abs(start - end).truncatingRemainder(dividingBy: 360)
        return min(raw, 360 - raw)
    }
}
