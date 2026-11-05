import MapKit
import SwiftUI

/// Recap map. Coordinates are copied once in `init`; `body` only draws them.
/// Pan and zoom only: no user location, compass, or guidance.
struct FlightRouteMap: View {
    private let segments: [[CLLocationCoordinate2D]]
    private let departure: CLLocationCoordinate2D?
    private let arrival: CLLocationCoordinate2D?
    private let departureCode: String
    private let arrivalCode: String
    private let kind: RouteDisplay.Kind
    private let summary: String
    @State private var position: MapCameraPosition

    init(route: RouteDisplay) {
        segments = route.segments.map { segment in
            segment.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        }
        departure = route.departure.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        arrival = route.arrival.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        departureCode = route.departureCode
        arrivalCode = route.arrivalCode
        kind = route.kind
        summary = route.summary
        if let camera = route.camera {
            _position = State(initialValue: .region(Self.region(camera)))
        } else {
            _position = State(initialValue: .automatic)
        }
    }

    var body: some View {
        Map(position: $position, interactionModes: [.pan, .zoom]) {
            ForEach(segments.indices, id: \.self) { index in
                MapPolyline(coordinates: segments[index])
                    .stroke(Color.accentColor, style: stroke)
            }
            if let departure {
                Marker(departureCode, systemImage: "airplane.departure", coordinate: departure)
            }
            if let arrival {
                Marker(arrivalCode, systemImage: "airplane.arrival", coordinate: arrival)
            }
        }
        .mapStyle(.standard(elevation: .realistic, emphasis: .muted,
                            pointsOfInterest: .excludingAll, showsTraffic: false))
        .mapControlVisibility(.hidden)
        .accessibilityHidden(true)
        .overlay {
            // Above the hidden map, so VoiceOver gets one summary and taps still reach the map.
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
                .accessibilityElement()
                .accessibilityLabel(summary)
                .accessibilityAddTraits(.isImage)
                .accessibilityIdentifier("detail.map")
        }
    }

    private var stroke: StrokeStyle {
        if kind == .approximate {
            StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [6, 5])
        } else {
            StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
        }
    }

    private static func region(_ camera: RouteDisplay.Camera) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: camera.centerLatitude, longitude: camera.centerLongitude),
            span: MKCoordinateSpan(latitudeDelta: camera.latitudeDelta, longitudeDelta: camera.longitudeDelta)
        )
    }
}
