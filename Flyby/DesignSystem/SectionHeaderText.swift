import SwiftUI

/// List section header in `label2`. The system header gray is just under
/// WCAG AA (4.5:1) on grouped backgrounds; `label2` is 7.1:1 light / 8.6:1 dark.
/// Explicit font and no forced uppercase so headers scale fully and look the
/// same on iOS 17 (which uppercases and caps header text by default) and iOS 26.
struct SectionHeaderText: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .textCase(nil)
            .foregroundStyle(Color.label2)
            .accessibilityAddTraits(.isHeader)
            // Lets the accessibility audit recognize section headers (see AccessibilityAuditUITests).
            .accessibilityIdentifier("header.\(title)")
    }
}
