# Spec: Platform fallbacks (v0.3, provisional)

**Deployment target: iOS 17.0** (MVP-PLAN, AC S1). Skyglass is designed for iOS 26 Liquid Glass and degrades gracefully on iOS 17 and 18.

## Rule
Feature views **never** call iOS 18 or iOS 26 APIs directly. Every gated API lives in `DesignSystem/` behind `if #available(iOS 26, *)` or `if #available(iOS 18, *)`, inside a Flyby wrapper. A lint/grep check in CI fails the build if `glassEffect`, `GlassEffectContainer`, `glassEffectID`, `.glass`, `.glassProminent`, `tabBarMinimizeBehavior`, `navigationTransition` or `matchedTransitionSource` appears outside `DesignSystem/`.

## API table
| API | Min iOS | Flyby wrapper | iOS 17 fallback |
|---|---|---|---|
| `.glassEffect(_:in:)`, `.interactive()` | 26 | `flybyGlass(cornerRadius:onMap:)` | `.background(.ultraThinMaterial, in: shape)` (+ `MapScrim` when `onMap`). Reduce Transparency → solid `surface` |
| `GlassEffectContainer`, `.glassEffectID` | 26 | `FlybyGlassGroup` | Plain `HStack`; chips cross-fade instead of morphing |
| `.buttonStyle(.glass)` / `.glassProminent` | 26 | `flybyGlassButton(prominent:)` | `.bordered` / `.borderedProminent`, `.buttonBorderShape(.circle/.capsule)`; same 40 pt visual / 44 pt hit area |
| `.tabBarMinimizeBehavior(.onScrollDown)` | 26 | `flybyTabBarMinimizeOnScroll()` | No-op |
| Floating glass tab bar, glass sheets, scroll-edge effect | 26 (system) | — (automatic) | Classic opaque tab bar and sheets. A 110 pt `bg` 85% → 0 gradient keeps the status bar legible on maps |
| `Tab(_:systemImage:value:)` | 18 | `FlybyTabView` (in RootView) | `.tabItem { Label(…) }.tag(TabID…)`, same ids `tab.*`, same Record intercept via `onChange(of:)` |
| `.matchedTransitionSource` / `.navigationTransition(.zoom)` | 18 | `flybyZoomSource` / `flybyZoomDestination` | Standard `NavigationStack` push |
| `Color.mix(with:by:)` | 18 | `Color.Flyby.altitude(_:)` | Stepped 3-stop ramp (`altLow / altMid / altHigh`) |
| `.presentationSizing`, `.scrollEdgeEffectStyle` | 18 / 26 | not used in Sprint 1 | — |

Already fine on iOS 17, so no gate is needed: SwiftUI `Map` content builder, `MapPolyline`, `Annotation`, `.mapStyle(.standard(elevation:emphasis:pointsOfInterest:showsTraffic:))`, `.mapControlVisibility`, `MKMapSnapshotter` / `MKStandardMapConfiguration`, `.sensoryFeedback`, `.symbolEffect(.replace/.bounce)`, `.contentTransition(.numericText())`, `ContentUnavailableView`, `.onChange(of:) { old, new in }`, `ImageRenderer`, `.presentationDetents`, `PhotosPicker`.

## Reference implementation
See `proposal.html` §09. Key parts:
```swift
@ViewBuilder func flybyGlass(cornerRadius: CGFloat = Radius.panel, onMap: Bool = false) -> some View {
    if #available(iOS 26, *) {
        self.background { if onMap { MapScrim(cornerRadius: cornerRadius) } }
            .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
    } else {
        self.background(.ultraThinMaterial, in: .rect(cornerRadius: cornerRadius, style: .continuous))
            .background { if onMap { MapScrim(cornerRadius: cornerRadius) } }
    }
}
```
`MapScrim` = `RoundedRectangle(cornerRadius:).fill(Color.Flyby.bg.opacity(scheme == .dark ? 0.7 : 0.6))`. See `accessibility.md` for the measured values.

## QA hooks
- AC (proposed): build and run on an **iOS 17.x simulator runtime**. Smoke-test the 5 tabs, Log sheet, Flight Detail and Share there, and on iOS 26.
- Snapshot tests per wrapper for both branches (render with `#available` forced via a test seam `DesignSystem.forceLegacy = true`).
