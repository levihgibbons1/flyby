import SwiftUI

// Liquid Glass on iOS 26+, frosted material on iOS 17–25.
// Glass is for navigation and controls only; content stays on solid surfaces
// (DESIGN_SYSTEM.md §2). With Reduce Transparency on, custom glass becomes solid.

extension View {
    /// Shrinks the floating tab bar while scrolling down (iOS 26+). No-op earlier.
    @ViewBuilder
    func flybyTabBarMinimizeOnScroll() -> some View {
        if #available(iOS 26.0, *) {
            tabBarMinimizeBehavior(.onScrollDown)
        } else {
            self
        }
    }

    /// Custom glass surface for floating controls and map panels.
    func flybyGlass<S: Shape>(in shape: S, interactive: Bool = false) -> some View {
        modifier(FlybyGlassModifier(shape: shape, interactive: interactive))
    }

    /// Secondary control: `.glass` on iOS 26+, a frosted capsule earlier.
    @ViewBuilder
    func flybyGlassButtonStyle() -> some View {
        if #available(iOS 26.0, *) {
            buttonStyle(.glass)
        } else {
            buttonStyle(FrostedButtonStyle())
        }
    }

    /// Primary action, tinted Flyby Blue: `.glassProminent` on iOS 26+,
    /// a bordered-prominent capsule earlier.
    @ViewBuilder
    func flybyGlassProminentButtonStyle() -> some View {
        if #available(iOS 26.0, *) {
            buttonStyle(.glassProminent)
        } else {
            buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
        }
    }
}

private struct FlybyGlassModifier<S: Shape>: ViewModifier {
    let shape: S
    let interactive: Bool

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        if reduceTransparency {
            content.background(Color(.secondarySystemGroupedBackground), in: shape)
        } else if #available(iOS 26.0, *) {
            content.glassEffect(interactive ? .regular.interactive() : .regular, in: shape)
        } else {
            content.background(.regularMaterial, in: shape)
        }
    }
}

/// iOS 17–25 stand-in for `.buttonStyle(.glass)`.
private struct FrostedButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .padding(.horizontal, 16)
            .frame(minHeight: 44)
            .background {
                if reduceTransparency {
                    Capsule().fill(Color(.secondarySystemGroupedBackground))
                } else {
                    Capsule().fill(.regularMaterial)
                }
            }
            .opacity(configuration.isPressed ? 0.7 : 1)
            .contentShape(Capsule())
    }
}
