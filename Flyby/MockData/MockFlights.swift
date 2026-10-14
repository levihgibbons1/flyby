import Foundation

/// Sample journal for Sprint 1. Names, tail numbers and notes are fictional.
/// Includes a 512-point track (Flight Detail performance check) and a flight
/// with no track (approximate route).
enum MockFlights {
    static let all: [Flight] = [kpaoKmry, ksqlKtvl, khafKsql, ksqlKsba]

    static let kpaoKmry: Flight = {
        let takeoff = date(2026, 10, 4, 10, 12)
        let duration: TimeInterval = 44 * 60
        return Flight(id: "kpao-kmry-20261004", date: takeoff, aircraftType: "Cessna 172S", tailNumber: "N739PA",
                      departure: MockAirports.kpao, arrival: MockAirports.kmry, route: "Direct",
                      takeoff: takeoff, landing: takeoff + duration,
                      flightDuration: duration, blockDuration: 55 * 60, maxAltitudeFeet: 5_500,
                      notes: "Coastal haze burned off over Santa Cruz. Smooth air the whole way.",
                      track: MockTrack.generate(from: MockAirports.kpao, to: MockAirports.kmry, points: 180,
                                                cruiseFeet: 5_500, takeoff: takeoff, duration: duration),
                      source: .recorded)
    }()

    static let ksqlKtvl: Flight = {
        let takeoff = date(2026, 9, 19, 16, 11)
        let duration: TimeInterval = 58 * 60
        return Flight(id: "ksql-ktvl-20260919", date: takeoff, aircraftType: "Cirrus SR22", tailNumber: "N482CD",
                      departure: MockAirports.ksql, arrival: MockAirports.ktvl, route: "SQL V6 SAC V200 TVL",
                      takeoff: takeoff, landing: takeoff + duration,
                      flightDuration: duration, blockDuration: 72 * 60, maxAltitudeFeet: 11_500,
                      notes: "Over the Sierra to Tahoe. Light chop past Placerville, glassy on the lake.",
                      visibility: .followers,
                      track: MockTrack.generate(from: MockAirports.ksql, to: MockAirports.ktvl, points: 512,
                                                cruiseFeet: 11_500, takeoff: takeoff, duration: duration, bow: 0.04),
                      source: .recorded)
    }()

    /// Entered by hand, no track: Flight Detail shows the approximate route.
    static let khafKsql: Flight = {
        let takeoff = date(2026, 9, 7, 17, 40)
        return Flight(id: "khaf-ksql-20260907", date: takeoff, aircraftType: "Cessna 172S", tailNumber: "N739PA",
                      departure: MockAirports.khaf, arrival: MockAirports.ksql, route: "Over the hills",
                      flightDuration: 22 * 60, maxAltitudeFeet: 2_500,
                      notes: "Sunset hop home over Crystal Springs.")
    }()

    static let ksqlKsba: Flight = {
        let takeoff = date(2026, 8, 22, 9, 5)
        let duration: TimeInterval = 108 * 60
        return Flight(id: "ksql-ksba-20260822", date: takeoff, aircraftType: "Cirrus SR22", tailNumber: "N482CD",
                      departure: MockAirports.ksql, arrival: MockAirports.ksba, route: "Coastal",
                      takeoff: takeoff, landing: takeoff + duration,
                      flightDuration: duration, blockDuration: 122 * 60, maxAltitudeFeet: 9_500,
                      notes: "Down the coast past Big Sur.",
                      track: MockTrack.generate(from: MockAirports.ksql, to: MockAirports.ksba, points: 300,
                                                cruiseFeet: 9_500, takeoff: takeoff, duration: duration, bow: 0.12),
                      source: .recorded)
    }()

    /// Pacific time, so the sample dates read the same in the Bay Area.
    private static func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .current
        let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
        return calendar.date(from: components) ?? Date(timeIntervalSince1970: 0)
    }
}
