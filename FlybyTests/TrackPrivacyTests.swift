import CoreLocation
import Foundation
import Testing
@testable import Flyby

struct TrackPrivacyTests {
    @Test func trimDropsOneNauticalMileFromEachEnd() {
        let points = line(fromLatitude: 37, stepNM: 0.25, count: 41)
        guard let originalStart = points.first, let originalEnd = points.last else {
            Issue.record("line was empty")
            return
        }
        let trimmed = TrackPrivacy.trim(points, distance: 1)
        #expect(!trimmed.tooShort)
        guard let start = trimmed.points.first, let end = trimmed.points.last else {
            Issue.record("trim removed the whole line")
            return
        }
        #expect(abs(Geo.distanceNM(start.coordinate, originalStart.coordinate) - 1) < 0.05)
        #expect(abs(Geo.distanceNM(end.coordinate, originalEnd.coordinate) - 1) < 0.05)
        #expect(trimmed.points.count >= 2)
        #expect(trimmed.points.count < points.count)
    }

    @Test func shortTrackHidesEndpointsInsteadOfTrimming() {
        let points = line(fromLatitude: 37, stepNM: 0.2, count: 3)
        let trimmed = TrackPrivacy.trim(points, distance: 1)
        #expect(trimmed.tooShort)
        #expect(trimmed.points.isEmpty)

        guard let only = points.first else {
            Issue.record("short line was empty")
            return
        }
        let single = TrackPrivacy.trim([only], distance: 1)
        #expect(single.tooShort)
        #expect(single.points.isEmpty)
        #expect(TrackPrivacy.trim([], distance: 1).tooShort)
    }

    @Test func zeroDistanceKeepsTheTrack() {
        let points = line(fromLatitude: 37, stepNM: 1, count: 6)
        let trimmed = TrackPrivacy.trim(points, distance: 0)
        #expect(!trimmed.tooShort)
        #expect(trimmed.points.count == points.count)
    }

    @Test func hidingHomeRemovesItsNameAndTheTrackBesideIt() {
        let model = RecapCardModel.make(flight: MockFlights.ksqlKtvl, selection: .sharingDefaults)
        expectHomeHidden(model)
        #expect(model.homeNote == TrackPrivacy.homeFieldNote)
        #expect(model.routeTitle.contains("BAY AREA"))
        #expect(model.routeTitle.contains("KTVL"))
        #expect(model.routeSpoken.contains("Bay Area"))
        #expect(model.routeSpoken.contains("Lake Tahoe"))
        #expect(model.visibleText.contains("Cirrus SR22"))
        #expect(model.visibleText.contains(RecapCardModel.disclaimer))
        #expect(!model.visibleText.contains("N482CD"))
        #expect(model.note == nil)
        expect(model.points, stayedOff: MockAirports.ksql, around: 1)
    }

    @Test func hidingHomeTrimsOnlyTheHomeEndWhenTrimIsOff() {
        var selection = RecapPrivacySelection.sharingDefaults
        selection.trimEnds = false
        let model = RecapCardModel.make(flight: MockFlights.ksqlKtvl, selection: selection)
        expectHomeHidden(model)
        expect(model.points, stayedOff: MockAirports.ksql, around: 1)
        guard let end = model.points.last else {
            Issue.record("arrival end missing")
            return
        }
        #expect(Geo.distanceNM(end.coordinate, MockAirports.ktvl.coordinate) < 0.2)
    }

    @Test func turningHideOffShowsTheFieldAndLeavesTheProfileAlone() {
        let profile = ProfileStore()
        var selection = RecapPrivacySelection(profile: profile)
        selection.hideHomeAirport = false
        selection.trimEnds = false
        let model = RecapCardModel.make(flight: MockFlights.ksqlKtvl, selection: selection)
        #expect(profile.hideHomeAirport)
        #expect(model.homeNote == nil)
        #expect(model.visibleText.contains("KSQL"))
        #expect(model.visibleText.contains("San Carlos"))
        guard let start = model.points.first else {
            Issue.record("track missing")
            return
        }
        #expect(Geo.distanceNM(start.coordinate, MockAirports.ksql.coordinate) < 0.2)
    }

    @Test func otherAirportsStayNamedWhenHomeIsHidden() {
        let model = RecapCardModel.make(flight: MockFlights.kpaoKmry, selection: .sharingDefaults)
        #expect(model.homeNote == nil)
        #expect(model.routeTitle == "KPAO → KMRY")
        #expect(model.routeSpoken.contains("Palo Alto"))
        #expect(model.routeSpoken.contains("Monterey"))
        #expect(!model.visibleText.localizedCaseInsensitiveContains("ksql"))
        #expect(!model.visibleText.localizedCaseInsensitiveContains("san carlos"))
        expect(model.points, stayedOff: MockAirports.kpao, around: 1)
        expect(model.points, stayedOff: MockAirports.kmry, around: 1)
    }

    @Test func approximateRouteToHomeDoesNotEndOnTheField() {
        let model = RecapCardModel.make(flight: MockFlights.khafKsql, selection: .sharingDefaults)
        expectHomeHidden(model)
        #expect(model.note == "Approximate route")
        #expect(model.routeTitle.contains("KHAF"))
        #expect(model.routeTitle.contains("BAY AREA"))
        #expect(model.approximate)
        guard let end = model.points.last else {
            Issue.record("approximate route missing")
            return
        }
        let fromHome = Geo.distanceNM(end.coordinate, MockAirports.ksql.coordinate)
        #expect(fromHome > 0.85)
        #expect(fromHome < 1.4)
    }

    @Test func veryShortTrackFallsBackToHiddenEndpoints() {
        let home = MockAirports.ksql
        let points = [
            TrackPoint(latitude: home.latitude, longitude: home.longitude, altitudeFeet: 100, timestamp: nil),
            TrackPoint(latitude: home.latitude + 0.002, longitude: home.longitude, altitudeFeet: 200, timestamp: nil),
        ]
        let flight = Flight(date: .now, aircraftType: "Cessna 172S",
                            departure: home, arrival: MockAirports.ktvl,
                            flightDuration: 600, track: points, source: .recorded)
        let model = RecapCardModel.make(flight: flight, selection: .sharingDefaults)
        #expect(model.note == TrackPrivacy.shortTrackNote)
        #expect(model.points.isEmpty)
        expectHomeHidden(model)
        #expect(model.routeTitle.contains("BAY AREA"))
        #expect(model.routeTitle.contains("KTVL"))
    }

    @Test func sameHomeAirportWithNoTrackDrawsNothing() {
        let flight = Flight(date: .now, aircraftType: "Cessna 172S",
                            departure: MockAirports.ksql, arrival: MockAirports.ksql,
                            flightDuration: 600)
        let model = RecapCardModel.make(flight: flight, selection: .sharingDefaults)
        #expect(model.note == "Route unavailable")
        #expect(model.points.isEmpty)
        expectHomeHidden(model)
    }

    private func line(fromLatitude latitude: Double, stepNM: Double, count: Int) -> [TrackPoint] {
        let step = stepNM / 60
        return (0..<count).map { index in
            TrackPoint(latitude: latitude + Double(index) * step,
                       longitude: -122.25,
                       altitudeFeet: 1_000,
                       timestamp: nil)
        }
    }

    private func expectHomeHidden(_ model: RecapCardModel, sourceLocation: SourceLocation = #_sourceLocation) {
        let text = model.visibleText
        #expect(!text.localizedCaseInsensitiveContains("ksql"), "home ICAO leaked", sourceLocation: sourceLocation)
        #expect(!text.localizedCaseInsensitiveContains("san carlos"), "home name leaked", sourceLocation: sourceLocation)
        #expect(!text.localizedCaseInsensitiveContains("sql"), "home code leaked", sourceLocation: sourceLocation)
    }

    private func expect(_ points: [TrackPoint], stayedOff airport: Airport, around nauticalMiles: Double,
                        sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(!points.isEmpty, "no points to measure", sourceLocation: sourceLocation)
        guard let closest = points.map({ Geo.distanceNM($0.coordinate, airport.coordinate) }).min() else { return }
        #expect(abs(closest - nauticalMiles) < 0.4, "closest point was \(closest) nm", sourceLocation: sourceLocation)
    }
}

extension RecapPrivacySelection {
    static var sharingDefaults: RecapPrivacySelection {
        RecapPrivacySelection(profile: ProfileStore())
    }
}
