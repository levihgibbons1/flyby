import SwiftUI
import UIKit

/// Fields on Log a Flight. Captions use `label2` because the placeholder gray
/// misses contrast. The field itself has no placeholder text.
struct LogTextField: View {
    let title: String
    @Binding var text: String
    let field: LogField
    var focus: FocusState<LogField?>.Binding
    var capitalization: TextInputAutocapitalization = .never
    var keyboard: UIKeyboardType = .default
    var axis: Axis = .horizontal
    var identifier: String?
    var label: String?
    var value: String?
    var hint: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color.label2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            entry
        }
    }

    @ViewBuilder private var entry: some View {
        if let hint, !hint.isEmpty {
            configuredInput.accessibilityHint(hint)
        } else {
            configuredInput
        }
    }

    private var configuredInput: some View {
        input
            .textInputAutocapitalization(capitalization)
            .autocorrectionDisabled(true)
            .keyboardType(keyboard)
            .focused(focus, equals: field)
            .frame(minHeight: 44)
            .accessibilityIdentifier(identifier ?? "log.field.\(field.identifier)")
            .accessibilityLabel(label ?? title)
            .accessibilityValue(value ?? text)
            .onSubmit { focus.wrappedValue = nil }
            .onChange(of: text) { _, newValue in
                let cleaned = field.cleansAsAirport
                    ? LogFlightDraft.cleanedAirportCode(newValue)
                    : (field.cleansAsDuration ? LogFlightDraft.cleanedDurationText(newValue) : newValue)
                if cleaned != newValue { text = cleaned }
            }
    }

    @ViewBuilder private var input: some View {
        if axis == .vertical {
            TextField("", text: $text, axis: .vertical)
                .lineLimit(1...4)
        } else {
            TextField("", text: $text)
        }
    }
}

/// Icon plus the words, so an error is never color alone.
struct LogFieldError: View {
    let message: String
    let identifier: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Image(systemName: "exclamationmark.triangle")
                .accessibilityHidden(true)
            Text(message)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.footnote)
        .foregroundStyle(Color.label2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
        .accessibilityIdentifier(identifier)
    }
}

enum LogField: Hashable {
    case aircraft, tail, departure, arrival, hours, minutes, route, notes

    var identifier: String {
        switch self {
        case .aircraft: "aircraft"
        case .tail: "tail"
        case .departure: "dep"
        case .arrival: "arr"
        case .hours: "durationHours"
        case .minutes: "durationMinutes"
        case .route: "route"
        case .notes: "notes"
        }
    }

    var cleansAsAirport: Bool {
        self == .departure || self == .arrival
    }

    var cleansAsDuration: Bool {
        self == .hours || self == .minutes
    }
}
