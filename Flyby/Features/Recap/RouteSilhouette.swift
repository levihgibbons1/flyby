import SwiftUI

/// The route as a plain line, drawn from the already-trimmed points.
/// No map tiles and no airport dots, so a hidden field has nothing to mark it.
struct RouteSilhouette: View {
    var points: [TrackPoint]
    var approximate: Bool

    var body: some View {
        Canvas { context, size in
            let path = Self.path(points: points, in: size)
            context.stroke(path,
                           with: .color(.white),
                           style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))
            var route = StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
            if approximate { route.dash = [7, 5] }
            context.stroke(path, with: .color(RecapPalette.route), style: route)
        }
        .accessibilityHidden(true)
    }

    /// Maps the track into `size`, keeping north up and the line inside a small inset.
    static func path(points: [TrackPoint], in size: CGSize) -> Path {
        let samples = unwrapped(points)
        guard samples.count >= 2, size.width > 1, size.height > 1 else { return Path() }
        guard let first = samples.first else { return Path() }

        var minLatitude = first.latitude
        var maxLatitude = first.latitude
        var minLongitude = first.longitude
        var maxLongitude = first.longitude
        for sample in samples.dropFirst() {
            minLatitude = min(minLatitude, sample.latitude)
            maxLatitude = max(maxLatitude, sample.latitude)
            minLongitude = min(minLongitude, sample.longitude)
            maxLongitude = max(maxLongitude, sample.longitude)
        }

        let latitudeSpan = max(maxLatitude - minLatitude, 0.02)
        let longitudeSpan = max(maxLongitude - minLongitude, 0.02)
        let midLatitude = (minLatitude + maxLatitude) / 2
        let longitudeScale = max(cos(midLatitude * .pi / 180), 0.2)
        let inset = min(size.width, size.height) * 0.08
        let availableWidth = size.width - inset * 2
        let availableHeight = size.height - inset * 2
        guard availableWidth > 1, availableHeight > 1 else { return Path() }

        let fit = min(availableWidth / (longitudeSpan * longitudeScale), availableHeight / latitudeSpan)
        let drawnWidth = longitudeSpan * longitudeScale * fit
        let drawnHeight = latitudeSpan * fit
        let originX = (size.width - drawnWidth) / 2
        let originY = (size.height - drawnHeight) / 2

        var path = Path()
        for (index, sample) in samples.enumerated() {
            let x = originX + (sample.longitude - minLongitude) * longitudeScale * fit
            let y = originY + (maxLatitude - sample.latitude) * fit
            let point = CGPoint(x: x, y: y)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        return path
    }

    private struct Sample {
        var latitude: Double
        var longitude: Double
    }

    /// Unwraps longitudes so a track that crosses ±180° doesn't streak across the card.
    private static func unwrapped(_ points: [TrackPoint]) -> [Sample] {
        guard let first = points.first else { return [] }
        var samples = [Sample(latitude: first.latitude, longitude: first.longitude)]
        for point in points.dropFirst() {
            guard let previous = samples.last else { break }
            var longitude = point.longitude
            while longitude - previous.longitude > 180 { longitude -= 360 }
            while previous.longitude - longitude > 180 { longitude += 360 }
            samples.append(Sample(latitude: point.latitude, longitude: longitude))
        }
        return samples
    }
}
