import CoreLocation
import Foundation

/// What the Flight Detail map draws. Built once per flight, outside `body`,
/// so scrolling does not rebuild the polyline.
///
/// A journal recap, not a navigation route: invalid points are dropped, a
/// missing track becomes a great-circle line, and a track that crosses the
/// antimeridian is split so the camera frames the short way around.
struct RouteDisplay: Equatable {
    enum Kind: Equatable {
        /// At least two usable recorded points.
        case track
        /// No usable track. A great-circle line between the airports.
        case approximate
        /// Nothing to draw (no track, and the airports are missing or the same).
        case unavailable
    }

    struct Coordinate: Equatable, Hashable {
        var latitude: Double
        var longitude: Double

        var location: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }

    /// Region that frames every drawn point, with padding. Longitude is the
    /// short span, including across the antimeridian.
    struct Camera: Equatable {
        var centerLatitude: Double
        var centerLongitude: Double
        var latitudeDelta: Double
        var longitudeDelta: Double
    }

    let kind: Kind
    /// Polyline pieces. Split where the route crosses ±180°.
    let segments: [[Coordinate]]
    let departure: Coordinate?
    let arrival: Coordinate?
    let camera: Camera?
    /// One VoiceOver sentence for the map.
    let summary: String
    let departureCode: String
    let arrivalCode: String

    init(flight: Flight) {
        let departureCode = flight.departure.icao
        let arrivalCode = flight.arrival.icao
        let cleaned = Self.cleaned(flight.track, flightDate: flight.date)
        if cleaned.count >= 2 {
            let samples = Self.simplify(Self.unwrap(cleaned))
            let segments = Self.split(samples)
            if !segments.isEmpty, let camera = Self.camera(for: samples) {
                self.init(kind: .track, segments: segments, camera: camera,
                          summary: Self.summary(.track, flight: flight),
                          departureCode: departureCode, arrivalCode: arrivalCode)
                return
            }
        }
        if let ends = Self.endpoints(of: flight) {
            let samples = Self.unwrap(Self.greatCircle(from: ends.start, to: ends.end))
            let segments = Self.split(samples)
            if !segments.isEmpty, let camera = Self.camera(for: samples) {
                self.init(kind: .approximate, segments: segments, camera: camera,
                          summary: Self.summary(.approximate, flight: flight),
                          departureCode: departureCode, arrivalCode: arrivalCode)
                return
            }
        }
        self.init(kind: .unavailable, segments: [], camera: nil,
                  summary: Self.summary(.unavailable, flight: flight),
                  departureCode: departureCode, arrivalCode: arrivalCode)
    }

    private init(kind: Kind, segments: [[Coordinate]], camera: Camera?, summary: String,
                 departureCode: String, arrivalCode: String) {
        self.kind = kind
        self.segments = segments
        self.departure = segments.first?.first
        self.arrival = segments.last?.last
        self.camera = camera
        self.summary = summary
        self.departureCode = departureCode
        self.arrivalCode = arrivalCode
    }

    // MARK: - Cleaning

    /// 5 m. Keeps the first and last point (maps.md).
    private static let simplifyToleranceDegrees = 5.0 / 111_320
    /// Extra room around the route so the line isn't on the edge of the map.
    private static let spanPadding = 1.24
    /// Short hops still show the field, not a rooftop.
    private static let minimumSpanDegrees = 0.2
    private static let greatCircleSamples = 48

    private static func cleaned(_ track: [TrackPoint], flightDate: Date) -> [Coordinate] {
        TrackSanitizer.cleaned(track, flightDate: flightDate)
            .map { Coordinate(latitude: $0.latitude, longitude: $0.longitude) }
    }

    private static func endpoints(of flight: Flight) -> (start: Coordinate, end: Coordinate)? {
        guard let start = coordinate(flight.departure), let end = coordinate(flight.arrival) else { return nil }
        guard Geo.distanceNM(start.location, end.location) > 0.05 else { return nil }
        return (start, end)
    }

    private static func coordinate(_ airport: Airport) -> Coordinate? {
        let coordinate = airport.coordinate
        guard CLLocationCoordinate2DIsValid(coordinate) else { return nil }
        if coordinate.latitude == 0, coordinate.longitude == 0 { return nil }
        return Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    private static func greatCircle(from start: Coordinate, to end: Coordinate) -> [Coordinate] {
        let steps = greatCircleSamples
        guard steps >= 2 else { return [start, end] }
        return (0..<steps).map { index in
            let fraction = Double(index) / Double(steps - 1)
            let point = Geo.interpolate(start.location, end.location, fraction: fraction)
            return Coordinate(latitude: point.latitude, longitude: point.longitude)
        }
    }

    // MARK: - Antimeridian and framing

    /// A point with longitude unwrapped so each step from the previous point is ≤ 180°.
    private struct Sample {
        var latitude: Double
        var unwrappedLongitude: Double

        var normalizedLongitude: Double {
            var value = unwrappedLongitude
            while value > 180 { value -= 360 }
            while value < -180 { value += 360 }
            return value
        }

        var coordinate: Coordinate {
            Coordinate(latitude: latitude, longitude: normalizedLongitude)
        }
    }

    private static func unwrap(_ coordinates: [Coordinate]) -> [Sample] {
        guard let first = coordinates.first else { return [] }
        var samples = [Sample(latitude: first.latitude, unwrappedLongitude: first.longitude)]
        for coordinate in coordinates.dropFirst() {
            guard let previous = samples.last else { break }
            var longitude = coordinate.longitude
            while longitude - previous.unwrappedLongitude > 180 { longitude -= 360 }
            while previous.unwrappedLongitude - longitude > 180 { longitude += 360 }
            samples.append(Sample(latitude: coordinate.latitude, unwrappedLongitude: longitude))
        }
        return samples
    }

    private static func simplify(_ samples: [Sample]) -> [Sample] {
        guard samples.count > 2 else { return samples }
        return simplify(samples, tolerance: simplifyToleranceDegrees)
    }

    /// Douglas–Peucker. Keeps the first and last sample.
    private static func simplify(_ samples: [Sample], tolerance: Double) -> [Sample] {
        guard samples.count > 2, let first = samples.first, let last = samples.last else { return samples }
        var farthest = 0.0
        var farthestIndex: Int?
        for index in samples.indices.dropFirst().dropLast() {
            let distance = perpendicularDistance(samples[index], first, last)
            if distance > farthest {
                farthest = distance
                farthestIndex = index
            }
        }
        guard farthest > tolerance, let splitIndex = farthestIndex else { return [first, last] }
        let left = simplify(Array(samples[...splitIndex]), tolerance: tolerance)
        let right = simplify(Array(samples[splitIndex...]), tolerance: tolerance)
        return Array(left.dropLast()) + right
    }

    private static func perpendicularDistance(_ point: Sample, _ start: Sample, _ end: Sample) -> Double {
        let scale = cos(point.latitude * .pi / 180)
        let startX = start.unwrappedLongitude * scale
        let startY = start.latitude
        let endX = end.unwrappedLongitude * scale
        let endY = end.latitude
        let pointX = point.unwrappedLongitude * scale
        let pointY = point.latitude
        let dx = endX - startX
        let dy = endY - startY
        let lengthSquared = dx * dx + dy * dy
        if lengthSquared < 1e-12 { return hypot(pointX - startX, pointY - startY) }
        let projection = ((pointX - startX) * dx + (pointY - startY) * dy) / lengthSquared
        let t = min(1, max(0, projection))
        return hypot(pointX - (startX + t * dx), pointY - (startY + t * dy))
    }

    private static func split(_ samples: [Sample]) -> [[Coordinate]] {
        guard let first = samples.first else { return [] }
        var segments: [[Coordinate]] = []
        var current = [first.coordinate]
        var previous = first
        for sample in samples.dropFirst() {
            if let cut = dateLineCut(from: previous, to: sample) {
                current.append(cut.approaching)
                if current.count >= 2 { segments.append(current) }
                current = [cut.departing, sample.coordinate]
            } else if abs(sample.normalizedLongitude - previous.normalizedLongitude) > 180 {
                // The step lands on the date line, so start a new segment at this point.
                if current.count >= 2 { segments.append(current) }
                current = [sample.coordinate]
            } else {
                current.append(sample.coordinate)
            }
            previous = sample
        }
        if current.count >= 2 { segments.append(current) }
        return segments
    }

    /// Points on each side of the date line, so a segment never draws the long way around.
    /// The side we leave uses +180 or −180, whichever is next to the previous point.
    private static func dateLineCut(from previous: Sample, to next: Sample) -> (approaching: Coordinate, departing: Coordinate)? {
        guard abs(next.normalizedLongitude - previous.normalizedLongitude) > 180 else { return nil }
        let span = next.unwrappedLongitude - previous.unwrappedLongitude
        guard abs(span) > 1e-9 else { return nil }
        let boundary = span > 0
            ? 180 + 360 * (floor((previous.unwrappedLongitude - 180) / 360) + 1)
            : -180 + 360 * (ceil((previous.unwrappedLongitude + 180) / 360) - 1)
        let fraction = (boundary - previous.unwrappedLongitude) / span
        guard fraction > 0, fraction < 1 else { return nil }
        let latitude = previous.latitude + (next.latitude - previous.latitude) * fraction
        let leaving = previous.normalizedLongitude >= 0 ? 180.0 : -180.0
        return (Coordinate(latitude: latitude, longitude: leaving),
                Coordinate(latitude: latitude, longitude: -leaving))
    }

    private static func camera(for samples: [Sample]) -> Camera? {
        guard let first = samples.first else { return nil }
        var minLatitude = first.latitude
        var maxLatitude = first.latitude
        var minLongitude = first.unwrappedLongitude
        var maxLongitude = first.unwrappedLongitude
        for sample in samples.dropFirst() {
            minLatitude = min(minLatitude, sample.latitude)
            maxLatitude = max(maxLatitude, sample.latitude)
            minLongitude = min(minLongitude, sample.unwrappedLongitude)
            maxLongitude = max(maxLongitude, sample.unwrappedLongitude)
        }
        let center = Sample(latitude: (minLatitude + maxLatitude) / 2,
                            unwrappedLongitude: (minLongitude + maxLongitude) / 2)
        return Camera(centerLatitude: center.latitude,
                      centerLongitude: center.normalizedLongitude,
                      latitudeDelta: max((maxLatitude - minLatitude) * spanPadding, minimumSpanDegrees),
                      longitudeDelta: max((maxLongitude - minLongitude) * spanPadding, minimumSpanDegrees))
    }

    private static func summary(_ kind: Kind, flight: Flight) -> String {
        let route = "\(flight.departure.name) to \(flight.arrival.name)"
        switch kind {
        case .track:
            let miles = FlightFormat.distance(flight.distanceNM)
            return "Route map, \(route), \(miles) nautical miles"
        case .approximate:
            return "Approximate route, not the flown track, \(route)"
        case .unavailable:
            return "Route unavailable"
        }
    }
}
