import SwiftUI

/// The share card: route line, stats, aircraft, date, Flyby, and the disclaimer.
///
/// Laid out at a fixed size and fixed text size. The share screen scales this
/// view down to fit the phone; the exported image is this same view at 3×.
struct RecapCardView: View {
    let model: RecapCardModel

    private var square: Bool { model.canvas == .square }

    var body: some View {
        VStack(alignment: .leading, spacing: square ? 6 : 12) {
            brand
            route
            if let homeNote = model.homeNote {
                homeField(homeNote)
            }
            Text(model.dateText)
                .font(.system(size: 13))
                .foregroundStyle(RecapPalette.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("recap.date")
            Text(model.aircraft)
                .font(.system(size: square ? 14 : 16, weight: .semibold))
                .foregroundStyle(RecapPalette.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("recap.aircraft")
            routeWell
            if model.points.count >= 2, let note = model.note {
                Text(note)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(RecapPalette.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("recap.note")
            }
            stats
            Spacer(minLength: 0)
            footer
        }
        .padding(square ? 16 : 22)
        .frame(width: model.canvas.pointSize.width,
               height: model.canvas.pointSize.height,
               alignment: .topLeading)
        .background {
            LinearGradient(colors: [RecapPalette.skyTop, RecapPalette.skyBottom],
                           startPoint: .top, endPoint: .bottom)
        }
        .accessibilityIdentifier("recap.preview")
    }

    private var brand: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(RecapPalette.mark)
                .frame(width: 22, height: 22)
                .overlay {
                    Text("F")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(RecapPalette.onMark)
                }
                .accessibilityHidden(true)
            Text(RecapCardModel.brand)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(RecapPalette.ink)
                .accessibilityIdentifier("recap.brand")
            Spacer(minLength: 0)
        }
    }

    private var route: some View {
        Text(model.routeTitle)
            .font(.system(size: square ? 22 : 30, weight: .semibold, design: .monospaced))
            .foregroundStyle(RecapPalette.ink)
            .lineLimit(2)
            .minimumScaleFactor(0.6)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(model.routeSpoken)
            .accessibilityValue(model.routeTitle)
            .accessibilityIdentifier("recap.route")
    }

    private func homeField(_ note: String) -> some View {
        Label(note, systemImage: "shield")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(RecapPalette.secondary)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(note)
            .accessibilityIdentifier("recap.homeNote")
    }

    private var routeWell: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(RecapPalette.panel)
            if model.points.count >= 2 {
                RouteSilhouette(points: model.points, approximate: model.approximate)
                    .padding(10)
            } else if let note = model.note {
                Text(note)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(RecapPalette.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(12)
                    .accessibilityIdentifier("recap.note")
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: square ? 88 : 220)
    }

    private var stats: some View {
        HStack(alignment: .top, spacing: 8) {
            stat("Flight time", value: model.durationText, identifier: "recap.stat.duration")
            stat("Distance", value: model.distanceText, identifier: "recap.stat.distance")
            stat("Max altitude", value: model.altitudeText, identifier: "recap.stat.altitude")
        }
    }

    private func stat(_ title: String, value: String, identifier: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(RecapPalette.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(value)
                .font(.system(size: square ? 13 : 16, weight: .semibold))
                .foregroundStyle(RecapPalette.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value)
        .accessibilityIdentifier(identifier)
    }

    private var footer: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(RecapCardModel.disclaimer)
                .font(.system(size: 11))
                .foregroundStyle(RecapPalette.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("recap.disclaimer")
            Spacer(minLength: 8)
            Text(RecapCardModel.brand)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(RecapPalette.ink)
        }
    }
}
