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

/// Presents the system share sheet from the view controller already on screen.
/// Share is the only caller. Nothing is uploaded.
enum RecapSharePresenter {
    static func present(_ image: UIImage) {
        guard let presenter = topViewController() else { return }
        guard !(presenter.presentedViewController is UIActivityViewController) else { return }
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.view.accessibilityIdentifier = "recap.shareSheet"
        if let popover = controller.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 1, height: 1)
            popover.permittedArrowDirections = []
        }
        presenter.present(controller, animated: true) {
            controller.view.accessibilityIdentifier = "recap.shareSheet"
        }
    }

    private static func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
            ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        let root = scene?.windows.first { $0.isKeyWindow }?.rootViewController
            ?? scene?.windows.first?.rootViewController
        return root.map(topmost)
    }

    private static func topmost(_ controller: UIViewController) -> UIViewController {
        if let presented = controller.presentedViewController, !presented.isBeingDismissed {
            return topmost(presented)
        }
        return controller
    }
}
