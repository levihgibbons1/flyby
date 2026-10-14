import Foundation


/// Airports available in Sprint 1. Logging validates DEP/ARR against this list.
/// Coordinates are approximate field locations.
enum MockAirports {
    static let ksql = Airport(icao: "KSQL", name: "San Carlos", region: "Bay Area", latitude: 37.5119, longitude: -122.2495)
    static let kpao = Airport(icao: "KPAO", name: "Palo Alto", region: "Bay Area", latitude: 37.4611, longitude: -122.1150)
    static let khaf = Airport(icao: "KHAF", name: "Half Moon Bay", region: "Bay Area", latitude: 37.5134, longitude: -122.5011)
    static let koak = Airport(icao: "KOAK", name: "Oakland", region: "Bay Area", latitude: 37.7213, longitude: -122.2208)
    static let khwd = Airport(icao: "KHWD", name: "Hayward Executive", region: "Bay Area", latitude: 37.6592, longitude: -122.1217)
    static let klvk = Airport(icao: "KLVK", name: "Livermore", region: "Bay Area", latitude: 37.6934, longitude: -121.8204)
    static let kapc = Airport(icao: "KAPC", name: "Napa County", region: "North Bay", latitude: 38.2132, longitude: -122.2807)
    static let ksts = Airport(icao: "KSTS", name: "Sonoma County", region: "North Bay", latitude: 38.5090, longitude: -122.8128)
    static let kmry = Airport(icao: "KMRY", name: "Monterey Regional", region: "Monterey Bay", latitude: 36.5870, longitude: -121.8430)
    static let kwvi = Airport(icao: "KWVI", name: "Watsonville", region: "Monterey Bay", latitude: 36.9357, longitude: -121.7896)
    static let ksns = Airport(icao: "KSNS", name: "Salinas", region: "Monterey Bay", latitude: 36.6628, longitude: -121.6064)
    static let ksac = Airport(icao: "KSAC", name: "Sacramento Executive", region: "Sacramento", latitude: 38.5125, longitude: -121.4935)
    static let ktvl = Airport(icao: "KTVL", name: "Lake Tahoe", region: "Lake Tahoe", latitude: 38.8939, longitude: -119.9953)
    static let ktrk = Airport(icao: "KTRK", name: "Truckee Tahoe", region: "Lake Tahoe", latitude: 39.3200, longitude: -120.1396)
    static let ksbp = Airport(icao: "KSBP", name: "San Luis Obispo", region: "Central Coast", latitude: 35.2368, longitude: -120.6424)
    static let ksba = Airport(icao: "KSBA", name: "Santa Barbara", region: "Central Coast", latitude: 34.4262, longitude: -119.8404)

    static let all: [Airport] = [
        ksql, kpao, khaf, koak, khwd, klvk, kapc, ksts, kmry, kwvi, ksns, ksac, ktvl, ktrk, ksbp, ksba,
    ]

    /// Case- and whitespace-insensitive ICAO lookup.
    static func airport(icao: String) -> Airport? {
        let code = icao.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        return all.first { $0.icao == code }
    }
}
