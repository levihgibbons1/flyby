# Spec: Motion & haptics (v0.2, provisional)

All motion respects **Reduce Motion**: movement becomes a cross-fade and the route appears already drawn. Glass motion is system-driven wherever possible.

| Moment | SwiftUI | Haptic |
|---|---|---|
| Route draw-on | `.trim(from: 0, to: p)`, `.timingCurve(0.22, 0.8, 0.18, 1, duration: 1.6)`; arrival pin `.spring(response: 0.35, dampingFraction: 0.55)` | `.impact(weight: .light)` on pin |
| Card → Detail | `.matchedTransitionSource` + `.navigationTransition(.zoom)`; glass sheet rises to medium detent, `.spring(response: 0.45, dampingFraction: 0.86)` | — |
| Glass morph | `GlassEffectContainer` + `.glassEffectID(_:in:)`; `.glassEffect(.regular.interactive())` on tappable glass; `.bouncy(duration: 0.4)` | `.selection` |
| Tab bar minimize | `.tabBarMinimizeBehavior(.onScrollDown)` (system) | — |
| Stat count-up | `.contentTransition(.numericText())`, `.spring(response: 0.6, dampingFraction: 0.9)` | — |
| Profile scrub | `.interactiveSpring(response: 0.25, dampingFraction: 0.9)` | `.selection` every 1,000 ft |
| Visibility change | `.symbolEffect(.replace)`, `.snappy(duration: 0.25)` | `.selection` |
| Save flight | `.spring(response: 0.5, dampingFraction: 0.8)`, `.move(edge: .top)` + `.opacity` | `.success` |
| Achievement unlocked | `.spring(response: 0.5, dampingFraction: 0.6)` + `.symbolEffect(.bounce)` | `.impact(.medium)` → `.success` |
| Tailwind (like) | `.symbolEffect(.bounce.up)` + numeric text | `.impact(weight: .light)` |
| Recap reveal | route draw, then stats `.spring(response: 0.55, dampingFraction: 0.85).delay(i * 0.04)` | — |
