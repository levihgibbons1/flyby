import SwiftUI

/// List section header in `label2`. The system header gray is just under
/// WCAG AA (4.5:1) on grouped backgrounds; `label2` is 7.1:1 light / 8.6:1 dark.
struct SectionHeaderText: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .foregroundStyle(Color.label2)
            .accessibilityAddTraits(.isHeader)
    }
}
