# Spec: Platform fallbacks (v0.3.1, provisional)

**Deployment target: iOS 17.0** (MVP-PLAN, AC S1). Skyglass is designed for iOS 26 Liquid Glass and degrades gracefully on iOS 17 and 18.

## Rule
Feature views **never** call iOS 18 or iOS 26 APIs directly. Every gated API lives in `DesignSystem/` behind `if #available(iOS 26, *)` or `if #available(iOS 18, *)`, inside a Flyby wrapper. A CI grep fails the build if a gated **API call** appears outside `DesignSystem/`. It matches call syntax only, so design tokens such as `Color.Flyby.glassStrong`, `glass.regular` or `mapScrim` never trip it (N3):
```sh
! grep -rnE '\.glassEffect\(|GlassEffectContainer|\.glassEffectID\(|buttonStyle\(\.glass(Prominent)?\)|\.tabBarMinimizeBehavior\(|\.navigationTransition\(|\.matchedTransitionSource\(' \
    --include='*.swift' Flyby/ | grep -v '/DesignSystem/'
```
(`Tab(` is not grepped because it's too generic; the iOS 18 tab path is covered by the iOS 17 build.)

## API table
| API | Min iOS | Flyby wrapper | iOS 17 fallback |
|---|---|---|---|
| `.glassEffect(_:in:)`, `.interactive()` | 26 | `flybyGlass(cornerRadius:onMap:)` | **On maps** (detail sheet, controls, pills): `MapScrim` + **`.thickMaterial`**. **Elsewhere** (chips, search field over the sky wash): **`.regularMaterial`**. Never `.ultraThinMaterial` or `.thinMaterial` under text (N2; see `accessibility.md` §2b). Reduce Transparency → solid `surface` |
| `GlassEffectContainer`, `.glassEffectID` | 26 | `FlybyGlassGroup` | Plain `HStack`; chips cross-fade instead of morphing |
| `.buttonStyle(.glass)` / `.glassProminent` | 26 | `flybyGlassButton(prominent:onMap:)` | `.bordered` / `.borderedProminent`, `.buttonBorderShape(.circle/.capsule)`; same 40 pt visual / 44 pt hit area. **On maps** the bordered fill is replaced by the `flybyGlass(onMap: true)` background (scrim + `.thickMaterial`), with a `label`-colored glyph (≥ 14:1) |
| `.tabBarMinimizeBehavior(.onScrollDown)` | 26 | `flybyTabBarMinimizeOnScroll()` | No-op |
| Floating glass tab bar, glass sheets, scroll-edge effect | 26 (system) | — (automatic) | Classic system tab bar and sheets (the Flight Detail sheet's content uses `flybyGlass(onMap: true)`, i.e. `.thickMaterial` + scrim). A 110 pt `bg` 85% → 0 gradient keeps the status bar legible on maps |
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
        self.background(onMap ? .thickMaterial : .regularMaterial,           // never .ultraThin under text
                        in: .rect(cornerRadius: cornerRadius, style: .continuous))
            .background { if onMap { MapScrim(cornerRadius: cornerRadius) } }
    }
}
```
`MapScrim` = `RoundedRectangle(cornerRadius:).fill(Color.Flyby.bg.opacity(scheme == .dark ? 0.7 : 0.6))`. See `accessibility.md` for the measured values.

## QA hooks
- **Simulator matrix (N6, matches the QA smoke test):**

| Runtime | Devices | Notes |
|---|---|---|
| iOS 17.x | **iPhone SE (3rd gen)** 375×667 · **iPhone 15 Pro Max** 430×932 | Build on SE/iOS 17; smoke-test the 5 tabs, Log sheet, Flight Detail and Share on both |
| iOS 26.x | iPhone SE (3rd gen) · iPhone 17 Pro Max 440×956 | The 440 pt width is covered on iOS 26 only (the 17 Pro Max can't run iOS 17) |

- Snapshot tests per wrapper for both branches. The legacy branch is forced through a test seam that **exists only in DEBUG builds** (N5):
```swift
enum DesignSystem {
#if DEBUG
    /// Test-only: forces the iOS 17 fallback branch in snapshot tests. Not compiled into Release.
    nonisolated(unsafe) static var forceLegacy = false
    static var useLegacy: Bool { forceLegacy }
#else
    @inline(__always) static var useLegacy: Bool { false }
#endif
}
// wrappers: if !DesignSystem.useLegacy, #available(iOS 26, *) { … } else { fallback }
```
- Release builds contain no `forceLegacy` symbol. A CI step runs `nm` on the Release binary and fails if `forceLegacy` is found.
