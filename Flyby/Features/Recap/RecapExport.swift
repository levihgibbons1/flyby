import SwiftUI
import UIKit

/// Renders a card to an image. Call `renderImage()` only from a Share or Save tap.
protocol RecapImageRendering {
    func renderImage() -> UIImage?
}

/// Counts renders so a share can prove nothing was drawn before the tap.
struct RecapExportSession {
    private(set) var renderCount = 0

    mutating func share(using renderer: RecapImageRendering) -> UIImage? {
        render(using: renderer)
    }

    /// Returns nil without rendering when Photos access was not granted.
    mutating func imageForSave(access: RecapPhotoAccess, using renderer: RecapImageRendering) -> UIImage? {
        guard access == .granted else { return nil }
        return render(using: renderer)
    }

    private mutating func render(using renderer: RecapImageRendering) -> UIImage? {
        renderCount += 1
        return renderer.renderImage()
    }
}

enum RecapPhotoAccess: Equatable {
    case granted
    case denied
}

/// `ImageRenderer` at the card's fixed size. Not created until the tap that needs pixels.
struct ImageRecapRenderer: RecapImageRendering {
    var model: RecapCardModel

    func renderImage() -> UIImage? {
        let size = model.canvas.pointSize
        let card = RecapCardView(model: model)
            .environment(\.colorScheme, .light)
            .dynamicTypeSize(.large)
            .frame(width: size.width, height: size.height)
        let renderer = ImageRenderer(content: card)
        renderer.scale = model.canvas.scale
        renderer.proposedSize = ProposedViewSize(width: size.width, height: size.height)
        renderer.isOpaque = true
        return renderer.uiImage
    }
}

/// The rendered card, held only while the system share sheet is on screen.
struct RecapShareImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

/// Presents the system share sheet from a host that is already on screen.
/// The sheet appears only after Share hands over an image.
struct RecapActivityPresenter: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> RecapShareHost {
        let host = RecapShareHost()
        host.onDismiss = { image = nil }
        return host
    }

    func updateUIViewController(_ controller: RecapShareHost, context: Context) {
        controller.onDismiss = { image = nil }
        controller.image = image
        // Presenting during a SwiftUI update is dropped. The next turn is on screen.
        DispatchQueue.main.async {
            controller.presentShareIfNeeded()
        }
    }

    final class RecapShareHost: UIViewController {
        var image: UIImage?
        var onDismiss: (() -> Void)?
        private var presentedToken: ObjectIdentifier?

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .clear
            view.isUserInteractionEnabled = false
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            presentShareIfNeeded()
        }

        func presentShareIfNeeded() {
            guard view.window != nil, presentedViewController == nil, let image else { return }
            let token = ObjectIdentifier(image)
            guard presentedToken != token else { return }
            presentedToken = token
            let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            controller.view.accessibilityIdentifier = "recap.shareSheet"
            if let popover = controller.popoverPresentationController {
                popover.sourceView = view
                popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
                popover.permittedArrowDirections = []
            }
            controller.completionWithItemsHandler = { [weak self] _, _, _, _ in
                DispatchQueue.main.async {
                    self?.presentedToken = nil
                    self?.image = nil
                    self?.onDismiss?()
                }
            }
            present(controller, animated: true) {
                controller.view.accessibilityIdentifier = "recap.shareSheet"
            }
        }
    }
}
