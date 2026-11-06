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

/// Shows the system share sheet. SwiftUI can't present `UIActivityViewController`
/// as the sheet itself, so this host presents it once it is on screen.
struct RecapActivityView: UIViewControllerRepresentable {
    let image: UIImage

    func makeUIViewController(context: Context) -> RecapShareHost {
        RecapShareHost(image: image)
    }

    func updateUIViewController(_ controller: RecapShareHost, context: Context) {}

    final class RecapShareHost: UIViewController {
        private let image: UIImage
        private var didPresent = false

        init(image: UIImage) {
            self.image = image
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { nil }

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .clear
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            guard !didPresent, presentedViewController == nil else { return }
            didPresent = true
            let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            controller.view.accessibilityIdentifier = "recap.shareSheet"
            if let popover = controller.popoverPresentationController {
                popover.sourceView = view
                popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
                popover.permittedArrowDirections = []
            }
            controller.completionWithItemsHandler = { [weak self] _, _, _, _ in
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                }
            }
            present(controller, animated: true)
        }
    }
}
