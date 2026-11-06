import SwiftUI

/// Log a Flight, presented from the Record tab. The pilot types the flight;
/// Flyby never records a live position, and the entry stays in memory.
struct LogFlightSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(FlightStore.self) private var store

    @State private var draft: LogFlightDraft
    @State private var baseline: LogFlightDraft
    @State private var confirmDiscard = false
    @State private var isPickingDate = false
    @FocusState private var focused: LogField?

    init() {
        let fresh = LogFlightDraft.fresh()
        _draft = State(initialValue: fresh)
        _baseline = State(initialValue: fresh)
    }

    var body: some View {
        NavigationStack {
            List {
                disclaimer
                flightSection
                routeSection
                timeSection
                notesSection
                visibilitySection
                privacySection
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Log a Flight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
        }
        .accessibilityIdentifier("log.sheet")
        .alert("Discard this flight?", isPresented: $confirmDiscard) {
            Button("Discard", role: .destructive) { dismiss() }
            Button("Keep Editing", role: .cancel) {}
        } message: {
            Text("Your changes will not be saved.")
        }
        .sheet(isPresented: $isPickingDate) {
            datePicker
        }
    }

    private var problems: LogFlightProblems { draft.problems() }

    private var disclaimer: some View {
        Section {
            Label("Personal journal · Not for navigation", systemImage: "info.circle")
                .font(.footnote)
                .foregroundStyle(Color.label2)
                .accessibilityIdentifier("log.disclaimer")
            Label("Flyby never records your live position.", systemImage: "location.slash")
                .font(.footnote)
                .foregroundStyle(Color.label2)
        }
    }

    private var flightSection: some View {
        Section {
            Button {
                focused = nil
                isPickingDate = true
            } label: {
                FactRow("Date", value: draft.date.formatted(date: .long, time: .omitted))
            }
            .accessibilityIdentifier("log.field.date")
            .accessibilityLabel("Date")
            .accessibilityValue(draft.date.formatted(date: .long, time: .omitted))

            LogTextField(title: "Aircraft", text: $draft.aircraftType, field: .aircraft, focus: $focused)
            if let message = aircraftInlineError {
                LogFieldError(message: message, identifier: "log.field.aircraft.error")
            }

            LogTextField(
                title: "Tail number",
                text: $draft.tailNumber,
                field: .tail,
                focus: $focused,
                capitalization: .characters,
                label: "Tail number, optional"
            )
        } header: {
            SectionHeaderText("Flight")
        }
    }

    private var routeSection: some View {
        Section {
            airportField(
                title: "From",
                text: $draft.departureCode,
                field: .departure,
                identifier: "log.field.dep",
                label: "From airport",
                errorIdentifier: "log.field.dep.error",
                error: departureInlineError
            )
            airportField(
                title: "To",
                text: $draft.arrivalCode,
                field: .arrival,
                identifier: "log.field.arr",
                label: "To airport",
                errorIdentifier: "log.field.arr.error",
                error: arrivalInlineError
            )
            LogTextField(
                title: "Route",
                text: $draft.route,
                field: .route,
                focus: $focused,
                capitalization: .words,
                label: "Route, optional"
            )
        } header: {
            SectionHeaderText("Route")
        }
    }

    private var timeSection: some View {
        Section {
            LogTextField(
                title: "Hours",
                text: $draft.durationHoursText,
                field: .hours,
                focus: $focused,
                keyboard: .numbersAndPunctuation,
                label: "Duration hours"
            )
            LogTextField(
                title: "Minutes",
                text: $draft.durationMinutesText,
                field: .minutes,
                focus: $focused,
                keyboard: .numbersAndPunctuation,
                label: "Duration minutes"
            )
            if let message = durationInlineError {
                LogFieldError(message: message, identifier: "log.field.duration.error")
            }
            if let duration = draft.resolvedDuration() {
                Text("Flight time \(FlightFormat.duration(duration))")
                    .font(.subheadline)
                    .foregroundStyle(Color.label2)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Flight time \(FlightFormat.spokenDuration(duration))")
            }

            Toggle(isOn: $draft.includesTimes) {
                Text("Add times")
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityIdentifier("log.times")
            .accessibilityLabel("Departure and arrival times")
            .accessibilityHint("Optional. Arrival must be after departure. You can enter a duration instead.")

            if draft.includesTimes {
                DatePicker("Departure", selection: $draft.departureTime, displayedComponents: .hourAndMinute)
                    .accessibilityIdentifier("log.time.out")
                    .accessibilityLabel("Departure time")
                DatePicker("Arrival", selection: $draft.arrivalTime, displayedComponents: .hourAndMinute)
                    .accessibilityIdentifier("log.time.in")
                    .accessibilityLabel("Arrival time")
                if let message = problems.times {
                    LogFieldError(message: message, identifier: "log.time.error")
                }
            }
            Text("Enter hours and minutes, or turn on times. Times are the same day, and arrival has to be later.")
                .font(.footnote)
                .foregroundStyle(Color.label2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        } header: {
            SectionHeaderText("Time")
        }
    }

    private var notesSection: some View {
        Section {
            LogTextField(
                title: "Notes",
                text: $draft.notes,
                field: .notes,
                focus: $focused,
                capitalization: .sentences,
                axis: .vertical,
                label: "Notes, optional"
            )
        } header: {
            SectionHeaderText("Notes")
        }
    }

    private var visibilitySection: some View {
        Section {
            ForEach(FlightVisibility.allCases) { option in
                visibilityButton(option)
            }
            Text("Private by default. Only you can see this flight until you choose another option.")
                .font(.footnote)
                .foregroundStyle(Color.label2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("log.visibility")
        } header: {
            SectionHeaderText("Who can see this flight")
        }
    }

    private var privacySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                Label("Home airport hidden when shared", systemImage: "shield")
                    .fixedSize(horizontal: false, vertical: true)
                Text("From your privacy setting in Profile, Settings.")
                    .font(.subheadline)
                    .foregroundStyle(Color.label2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Home airport hidden when shared, from your privacy setting")
            .accessibilityIdentifier("log.privacyNote")
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", systemImage: "xmark", action: cancel)
                .accessibilityIdentifier("log.cancel")
                .accessibilityLabel("Cancel")
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Save", systemImage: "checkmark", action: save)
                .disabled(!problems.isValid)
                .accessibilityIdentifier("log.save")
                .accessibilityLabel("Save flight")
                .accessibilityHint(problems.saveHint)
        }
        ToolbarItem(placement: .keyboard) {
            Button("Done") { focused = nil }
                .accessibilityIdentifier("log.keyboard.done")
        }
    }

    private var datePicker: some View {
        NavigationStack {
            DatePicker("Date", selection: $draft.date, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding()
                .navigationTitle("Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { isPickingDate = false }
                            .accessibilityIdentifier("log.field.date.done")
                    }
                }
        }
        .presentationDetents([.medium, .large])
    }

    private var aircraftInlineError: String? {
        draft.aircraftType.isEmpty ? nil : problems.aircraft
    }

    private var departureInlineError: String? {
        inlineAirportError(draft.departureCode, message: problems.departure)
    }

    private var arrivalInlineError: String? {
        inlineAirportError(draft.arrivalCode, message: problems.arrival)
    }

    private var durationInlineError: String? {
        let typed = !draft.durationHoursText.isEmpty || !draft.durationMinutesText.isEmpty
        return typed ? problems.duration : nil
    }

    private func inlineAirportError(_ raw: String, message: String?) -> String? {
        raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : message
    }

    /// "KSQL, San Carlos", so VoiceOver hears the code and the name.
    private func spokenAirport(_ code: String) -> String? {
        guard let airport = MockAirports.airport(icao: code) else { return nil }
        return "\(airport.icao), \(airport.name)"
    }

    @ViewBuilder
    private func airportField(
        title: String,
        text: Binding<String>,
        field: LogField,
        identifier: String,
        label: String,
        errorIdentifier: String,
        error: String?
    ) -> some View {
        LogTextField(
            title: title,
            text: text,
            field: field,
            focus: $focused,
            capitalization: .characters,
            keyboard: .asciiCapable,
            identifier: identifier,
            label: label,
            value: spokenAirport(text.wrappedValue),
            hint: error ?? "4-letter ICAO code"
        )
        if let airport = MockAirports.airport(icao: text.wrappedValue) {
            Text(airport.name)
                .font(.subheadline)
                .foregroundStyle(Color.label2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
        if let error {
            LogFieldError(message: error, identifier: errorIdentifier)
        }
    }

    private func visibilityButton(_ option: FlightVisibility) -> some View {
        let selected = draft.visibility == option
        let icon = Image(systemName: option.systemImage)
            .accessibilityHidden(true)
            .frame(width: 24)
        let titles = VStack(alignment: .leading, spacing: 2) {
            Text(option == .private ? "Private · Default" : option.title)
                .fixedSize(horizontal: false, vertical: true)
            Text(option.summary)
                .font(.subheadline)
                .foregroundStyle(Color.label2)
                .fixedSize(horizontal: false, vertical: true)
        }
        let check = Image(systemName: "checkmark").accessibilityHidden(true)
        return Button {
            draft.visibility = option
        } label: {
            // One line when it fits; stacked when the summary would be cut off
            // (iPhone SE, and every phone at accessibility sizes).
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: 12) {
                    icon
                    titles
                    Spacer(minLength: 8)
                    if selected { check }
                }
                .fixedSize(horizontal: true, vertical: false)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .center, spacing: 12) {
                        icon
                        titles
                    }
                    if selected { check }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        }
        .accessibilityIdentifier("log.visibility.\(option.rawValue)")
        .accessibilityLabel(visibilityLabel(option, selected: selected))
        .accessibilityHint(option.summary)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func visibilityLabel(_ option: FlightVisibility, selected: Bool) -> String {
        if option == .private && selected { return "Private, selected, default" }
        if selected { return "\(option.title), selected" }
        return option.title
    }

    private func cancel() {
        focused = nil
        if draft.hasEdits(since: baseline) {
            confirmDiscard = true
        } else {
            dismiss()
        }
    }

    private func save() {
        guard let flight = draft.makeFlight() else { return }
        store.add(flight)
        focused = nil
        dismiss()
    }
}

#Preview("Light") {
    LogFlightSheet()
        .environment(FlightStore())
}

#Preview("Dark") {
    LogFlightSheet()
        .environment(FlightStore())
        .preferredColorScheme(.dark)
}
