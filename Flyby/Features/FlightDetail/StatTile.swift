import SwiftUI

/// One flight number. The value wraps instead of truncating, and VoiceOver
/// reads the title with a spoken value ("44 minutes", not "0:44").
struct StatTile: View {
    let title: String
    let value: String
    var spokenValue: String
    let identifier: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.label2)
                .fixedSize(horizontal: false, vertical: true)
            Text(value)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.primary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(spokenValue)
        .accessibilityIdentifier(identifier)
    }
}
