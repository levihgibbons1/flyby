import SwiftUI

/// "Title ........ value" row. Stacks when the pair doesn't fit on one line
/// (narrow phones, and every phone at accessibility sizes). The value uses
/// `label2` (AA in both modes).
struct FactRow: View {
    let title: String
    let value: String

    init(_ title: String, value: String) {
        self.title = title
        self.value = value
    }

    var body: some View {
        // `fixedSize` makes the side-by-side row report its full width, so
        // ViewThatFits stacks instead of letting the texts truncate. Truncation
        // fails the accessibility audit's text-clipped check.
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(title)
                Spacer(minLength: 12)
                Text(value)
                    .foregroundStyle(Color.label2)
                    .multilineTextAlignment(.trailing)
            }
            .fixedSize(horizontal: true, vertical: false)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fixedSize(horizontal: false, vertical: true)
                Text(value)
                    .foregroundStyle(Color.label2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(minHeight: 44)
        // One element: VoiceOver reads "Hours, 3.9".
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }
}
