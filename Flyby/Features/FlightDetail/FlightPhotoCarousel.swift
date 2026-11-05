import SwiftUI

/// Horizontal row of mock trip photos. Captions wrap; the pictures are
/// decorative and VoiceOver reads one label per photo.
struct FlightPhotoCarousel: View {
    let photos: [FlightPhoto]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionHeaderText("Photos")
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                        card(photo, index: index)
                    }
                }
            }
            .accessibilityIdentifier("detail.photos")
        }
    }

    private func card(_ photo: FlightPhoto, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                LinearGradient(colors: colors(photo.style), startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: photo.symbolName)
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
                    .accessibilityHidden(true)
            }
            .frame(width: 200, height: 132)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(photo.caption)
                .font(.caption)
                .foregroundStyle(Color.label2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: 200, alignment: .leading)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Photo \(index + 1) of \(photos.count), \(photo.caption)")
        .accessibilityAddTraits(.isImage)
        .accessibilityIdentifier("detail.photo.\(photo.id)")
    }

    private func colors(_ style: FlightPhoto.Style) -> [Color] {
        switch style {
        case .coast: [.blue, .teal]
        case .sierra: [.indigo, .brown]
        case .sunset: [.orange, .pink]
        case .lake: [.cyan, .blue]
        case .field: [.green, .teal]
        case .cabin: [.blue, .indigo]
        }
    }
}
