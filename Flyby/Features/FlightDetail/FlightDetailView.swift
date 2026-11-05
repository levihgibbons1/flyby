import SwiftUI

/// Flight Detail: a recap of one flight. The map is for looking, not navigating.
struct FlightDetailView: View {
    let flight: Flight

    /// Computed when the screen opens. Later `body` calls reuse this value,
    /// so the polyline is not rebuilt on every frame of a scroll.
    @State private var route: RouteDisplay
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(flight: Flight) {
        self.flight = flight
        _route = State(initialValue: RouteDisplay(flight: flight))
    }

    var body: some View {
        GeometryReader { proxy in
            let mapHeight = min(max(proxy.size.height * 0.34, 180), 240)
            VStack(spacing: 0) {
                routeSection(mapHeight: mapHeight)
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        stats
                        if !flight.tailNumber.isEmpty {
                            FactRow("Tail number", value: flight.tailNumber)
                                .accessibilityIdentifier("detail.tail")
                        }
                        if !flight.notes.isEmpty {
                            notes
                        }
                        if !flight.photos.isEmpty {
                            FlightPhotoCarousel(photos: flight.photos)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier("detail.scroll")
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(flight.routeTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func routeSection(mapHeight: CGFloat) -> some View {
        VStack(spacing: 0) {
            Group {
                if route.kind == .unavailable {
                    unavailableRoute
                } else {
                    FlightRouteMap(route: route)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: mapHeight)

            if route.kind == .approximate {
                Text("Approximate route")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.label2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .accessibilityIdentifier("detail.approximate")
            }

            Label("Personal journal · Not for navigation", systemImage: "info.circle")
                .font(.caption)
                .foregroundStyle(Color.label2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .accessibilityIdentifier("detail.disclaimer")
        }
    }

    private var unavailableRoute: some View {
        VStack(spacing: 8) {
            Image(systemName: "map")
                .font(.title2)
                .accessibilityHidden(true)
            Text("Route unavailable")
                .font(.headline)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(Color.label2)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Route unavailable")
        .accessibilityIdentifier("map.placeholder")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(flight.routeTitle)
                .font(.title2.monospaced().weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(flight.routeSpokenTitle)
            Text(flight.date.formatted(date: .long, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(Color.label2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel("Date")
                .accessibilityValue(flight.date.formatted(date: .long, time: .omitted))
                .accessibilityIdentifier("detail.date")
            VisibilityLabel(visibility: flight.visibility)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.secondarySystemGroupedBackground), in: Capsule())
                .accessibilityIdentifier("detail.visibility")
        }
    }

    private var stats: some View {
        VStack(spacing: 12) {
            if dynamicTypeSize.isAccessibilitySize {
                durationTile
                distanceTile
                altitudeTile
                aircraftTile
            } else {
                HStack(alignment: .top, spacing: 12) {
                    durationTile
                    distanceTile
                }
                HStack(alignment: .top, spacing: 12) {
                    altitudeTile
                    aircraftTile
                }
            }
        }
    }

    private var durationTile: some View {
        StatTile(title: "Duration",
                 value: FlightFormat.duration(flight.flightDuration),
                 spokenValue: FlightFormat.spokenDuration(flight.flightDuration),
                 identifier: "detail.stat.duration")
    }

    private var distanceTile: some View {
        StatTile(title: "Distance",
                 value: "\(FlightFormat.distance(flight.distanceNM)) nm",
                 spokenValue: "\(FlightFormat.distance(flight.distanceNM)) nautical miles",
                 identifier: "detail.stat.distance")
    }

    private var altitudeTile: some View {
        let spoken: String
        let value: String
        if let feet = flight.maxAltitudeFeet {
            value = "\(FlightFormat.altitude(feet)) ft"
            spoken = "\(FlightFormat.altitude(feet)) feet"
        } else {
            value = "—"
            spoken = "Not recorded"
        }
        return StatTile(title: "Max altitude", value: value, spokenValue: spoken,
                        identifier: "detail.stat.maxAlt")
    }

    private var aircraftTile: some View {
        StatTile(title: "Aircraft",
                 value: flight.aircraftType.isEmpty ? "—" : flight.aircraftType,
                 spokenValue: flight.aircraftType.isEmpty ? "Not recorded" : flight.aircraftType,
                 identifier: "detail.stat.aircraft")
    }

    private var notes: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionHeaderText("Notes")
            Text(flight.notes)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("detail.notes")
        }
    }
}

#Preview("Track") {
    NavigationStack {
        FlightDetailView(flight: MockFlights.kpaoKmry)
    }
}

#Preview("Approximate") {
    NavigationStack {
        FlightDetailView(flight: MockFlights.khafKsql)
    }
}

#Preview("Dark") {
    NavigationStack {
        FlightDetailView(flight: MockFlights.ksqlKtvl)
    }
    .preferredColorScheme(.dark)
}
