import SwiftUI

/// "Title ........ value" row. Stacks at accessibility sizes so long values
/// keep the full width. The value uses `label2` (AA in both modes).
struct FactRow: View {
    let title: String
    let value: String

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(_ title: String, value: String) {
        self.title = title
        self.value = value
    }

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 2))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline))
        layout {
            Text(title)
            if !dynamicTypeSize.isAccessibilitySize {
                Spacer(minLength: 12)
            }
            Text(value)
                .foregroundStyle(Color.label2)
                .multilineTextAlignment(dynamicTypeSize.isAccessibilitySize ? .leading : .trailing)
        }
        .frame(minHeight: 44)
        // One element: VoiceOver reads "Hours, 3.9".
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }
}
