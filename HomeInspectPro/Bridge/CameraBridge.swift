import AVFoundation
import HotwireNative
import UIKit

public final class CameraBridge: BridgeComponent {
    public override class var name: String { "camera" }

    private var pickerDelegate: CameraPickerDelegate?

    public override func onReceive(message: Message) {
        guard message.event == "capture" else { return }
        presentCamera()
    }

    private func presentCamera() {
        guard let viewController = delegate?.destination as? UIViewController else { return }

        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self else { return }

            guard granted else {
                self.replyWithError("Camera permission denied")
                return
            }

            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                let delegate = CameraPickerDelegate { [weak self] image in
                    self?.replyWithImage(image)
                } onCancel: { [weak self] in
                    self?.replyWithError("Camera cancelled")
                }
                picker.delegate = delegate
                self.pickerDelegate = delegate
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

private final class CameraPickerDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let onPick: (UIImage) -> Void
    private let onCancel: () -> Void

    init(onPick: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
        self.onPick = onPick
        self.onCancel = onCancel
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            onPick(image)
        } else {
            onCancel()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        onCancel()
    }
}
