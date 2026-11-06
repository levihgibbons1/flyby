import SwiftUI

/// Fixed light colors for the exported card.
/// Chosen so the card stays legible in light and dark mode: it does not use
/// the system label colors, which would flip with the phone's appearance.
enum RecapPalette {
    static let skyTop = Color(red: 0.93, green: 0.96, blue: 0.99)
    static let skyBottom = Color(red: 0.75, green: 0.86, blue: 0.96)
    static let ink = Color(red: 0.08, green: 0.11, blue: 0.16)
    static let secondary = Color(red: 0.27, green: 0.34, blue: 0.43)
    static let route = Color(red: 0.11, green: 0.40, blue: 0.86)
    static let panel = Color(red: 0.97, green: 0.98, blue: 1.0)
    static let mark = Color(red: 0.06, green: 0.24, blue: 0.55)
    static let onMark = Color.white
}
