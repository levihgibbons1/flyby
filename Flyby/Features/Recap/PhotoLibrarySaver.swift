import Photos
import UIKit

/// Add-only Photos access. Constructed and called from the Save button, nowhere else.
struct PhotoLibrarySaver {
    func requestAddOnly() async -> RecapPhotoAccess {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        switch status {
        case .authorized, .limited:
            return .granted
        case .denied, .restricted, .notDetermined:
            return .denied
        @unknown default:
            return .denied
        }
    }

    func save(_ image: UIImage) async -> Bool {
        guard let data = image.pngData() else { return false }
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                guard let saved = UIImage(data: data) else { return }
                PHAssetChangeRequest.creationRequestForAsset(from: saved)
            } completionHandler: { success, _ in
                continuation.resume(returning: success)
            }
        }
    }
}
