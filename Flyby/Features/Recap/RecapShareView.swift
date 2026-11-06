import SwiftUI
import UIKit

/// Preview of one flight's recap. The image is created only when Share or Save is tapped.
///
/// Hide home airport and trim start here as a copy of the profile settings.
/// Moving a toggle updates the preview and does not write the profile back.
struct RecapShareView: View {
    let flight: Flight

    @Environment(ProfileStore.self) private var profile
    @State private var selection = RecapPrivacySelection(profile: ProfileStore())
    @State private var didLoadPrivacy = false
    @State private var export = RecapExportSession()
    @State private var errorMessage: String?
    @State private var photoDenied = false
    @State private var savedMessage: String?
    @State private var isSaving = false
    @State private var shareImage: RecapShareImage?

    private var model: RecapCardModel {
        RecapCardModel.make(flight: flight, selection: selection)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                preview
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            // Toggles stay in the bottom bar. Under the full-size card they sit
            // behind Share and Save, so a tap never reaches them.
            .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
            .navigationTitle("Share Recap")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: loadPrivacy)
            .background {
                RecapActivityPresenter(image: shareImageBinding)
            }
        }
    }

    /// The rendered image, presented by the host already on screen.
    /// A second sheet never gets a chance to cover the share controller.
    private var shareImageBinding: Binding<UIImage?> {
        Binding(
            get: { shareImage?.image },
            set: { newValue in
                if newValue == nil { shareImage = nil }
            }
        )
    }

    /// Full card, in the fixed export style. The scroll view fits it on a small phone.
    /// Scaling it down would push the disclaimer out of the accessibility tree.
    private var preview: some View {
        RecapCardView(model: model)
            .environment(\.colorScheme, .light)
            .dynamicTypeSize(.large)
            .frame(maxWidth: .infinity)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Size", selection: $selection.canvas) {
                ForEach(RecapCanvas.allCases) { canvas in
                    Text(canvas.title).tag(canvas)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("recap.size")

            toggles
            Text("Your default: \(selection.savedHideHomeDefault ? "On" : "Off") · this share only")
                .font(.footnote)
                .foregroundStyle(Color.label2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("recap.shareOnly")

            if let errorMessage {
                status(errorMessage, symbol: "exclamationmark.triangle", identifier: "recap.error")
            }
            if photoDenied {
                photosDenied
            }
            if let savedMessage {
                status(savedMessage, symbol: "checkmark.circle", identifier: "recap.saved")
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var toggles: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle("Hide home airport", isOn: $selection.hideHomeAirport)
                .accessibilityIdentifier("recap.toggle.hideHome")
            Toggle("Trim track start/end", isOn: $selection.trimEnds)
                .accessibilityIdentifier("recap.toggle.trim")
        }
    }

    private var photosDenied: some View {
        VStack(alignment: .leading, spacing: 8) {
            status("Flyby can't save to Photos", symbol: "photo", identifier: "recap.error")
            Text("Allow Add Photos Only in Settings, or share the image instead.")
                .font(.subheadline)
                .foregroundStyle(Color.label2)
                .fixedSize(horizontal: false, vertical: true)
            Button("Open Settings", action: openSettings)
                .frame(minHeight: 44)
            Button("Share instead", action: share)
                .frame(minHeight: 44)
        }
    }

    private func status(_ text: String, symbol: String, identifier: String) -> some View {
        Label(text, systemImage: symbol)
            .font(.subheadline)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(text)
            .accessibilityIdentifier(identifier)
    }

    private var bottomBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls
            actions
        }
        .padding(.top, 8)
        .background(.bar)
    }

    private var actions: some View {
        VStack(spacing: 8) {
            Button(action: share) {
                Text("Share")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("recap.share")

            Button(action: { Task { await saveToPhotos() } }) {
                Text(isSaving ? "Saving…" : "Save to Photos")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.bordered)
            .disabled(isSaving)
            .accessibilityIdentifier("recap.save")
        }
        .padding(16)
        .background(.bar)
    }

    /// Copies the profile once. Later toggle changes stay on this share.
    private func loadPrivacy() {
        guard !didLoadPrivacy else { return }
        didLoadPrivacy = true
        let canvas = selection.canvas
        selection = RecapPrivacySelection(profile: profile)
        selection.canvas = canvas
    }

    private func share() {
        photoDenied = false
        guard let image = export.share(using: ImageRecapRenderer(model: model)) else {
            savedMessage = nil
            errorMessage = "Couldn't create the image. Your flight is safe."
            return
        }
        errorMessage = nil
        shareImage = RecapShareImage(image: image)
    }

    private func saveToPhotos() async {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }

        let access = await PhotoLibrarySaver().requestAddOnly()
        guard access == .granted else {
            photoDenied = true
            errorMessage = nil
            savedMessage = nil
            return
        }
        guard let image = export.imageForSave(access: access, using: ImageRecapRenderer(model: model)) else {
            photoDenied = false
            savedMessage = nil
            errorMessage = "Couldn't create the image. Your flight is safe."
            return
        }
        if await PhotoLibrarySaver().save(image) {
            photoDenied = false
            errorMessage = nil
            savedMessage = "Saved to Photos"
        } else {
            savedMessage = nil
            errorMessage = "Couldn't create the image. Your flight is safe."
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

#Preview("Home field hidden") {
    RecapShareView(flight: MockFlights.ksqlKtvl)
        .environment(ProfileStore())
}
