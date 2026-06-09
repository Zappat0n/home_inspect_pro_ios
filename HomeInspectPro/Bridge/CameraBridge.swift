import AVFoundation
import HotwireNative
import UIKit

public final class CameraBridge: BridgeComponent {
    override class var name: String { "camera" }

    override func onReceive(message: Message) {
        guard message.event == "capture" else { return }
        presentCamera()
    }

    private func presentCamera() {
        guard let viewController = delegate?.destination as? UIViewController else { return }

        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard granted else {
                self?.replyWithError("Camera permission denied")
                return
            }

            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                viewController.present(picker, animated: true)
            }
        }
    }

    private func replyWithImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            replyWithError("Failed to encode image")
            return
        }

        let base64 = data.base64EncodedString()
        let dataURI = "data:image/jpeg;base64,\(base64)"

        reply(to: "capture", with: ["image": dataURI])
    }

    private func replyWithError(_ error: String) {
        reply(to: "error", with: ["message": error])
    }
}

extension CameraBridge: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            replyWithImage(image)
        } else {
            replyWithError("No image captured")
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        replyWithError("Camera cancelled")
    }
}
