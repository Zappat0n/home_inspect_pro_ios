import HotwireNative
import PencilKit
import UIKit

public final class SignatureBridge: BridgeComponent {
    public override class var name: String { "signature" }

    private var signatureController: SignatureViewController?

    public override func onReceive(message: Message) {
        switch message.event {
        case "capture":
            presentSignatureCapture()
        case "clear":
            reply(to: "clear", with: ["image": ""])
        default:
            break
        }
    }

    private func presentSignatureCapture() {
        guard let viewController = delegate?.destination as? UIViewController else { return }

        let controller = SignatureViewController { [weak self] image in
            self?.replyWithSignature(image)
        } onCancel: { [weak self] in
            self?.replyWithError("Signature cancelled")
        }
        signatureController = controller

        let nav = UINavigationController(rootViewController: controller)
        viewController.present(nav, animated: true)
    }

    private func replyWithSignature(_ image: UIImage) {
        guard let data = image.pngData() else {
            replyWithError("Failed to encode signature")
            return
        }

        let base64 = data.base64EncodedString()
        let dataURI = "data:image/png;base64,\(base64)"

        reply(to: "capture", with: ["image": dataURI])
    }

    private func replyWithError(_ error: String) {
        reply(to: "error", with: ["message": error])
    }
}

// MARK: - Signature View Controller

private final class SignatureViewController: UIViewController {
    private let canvasView = PKCanvasView()
    private let toolPicker = PKToolPicker()
    private let onDone: (UIImage) -> Void
    private let onCancel: () -> Void

    init(onDone: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
        self.onDone = onDone
        self.onCancel = onCancel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCanvas()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        canvasView.becomeFirstResponder()
    }

    private func setupUI() {
        title = "Signature"
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )

        let clearButton = UIButton(type: .system)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false

        let promptLabel = UILabel()
        promptLabel.text = "Please sign above"
        promptLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        promptLabel.textColor = .secondaryLabel
        promptLabel.translatesAutoresizingMaskIntoConstraints = false

        let lineView = UIView()
        lineView.backgroundColor = .separator
        lineView.translatesAutoresizingMaskIntoConstraints = false

        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.layer.borderColor = UIColor.separator.cgColor
        canvasView.layer.borderWidth = 1
        canvasView.layer.cornerRadius = 8

        view.addSubview(promptLabel)
        view.addSubview(canvasView)
        view.addSubview(lineView)
        view.addSubview(clearButton)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            promptLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 16),
            promptLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            canvasView.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 12),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            canvasView.heightAnchor.constraint(equalToConstant: 200),

            lineView.topAnchor.constraint(equalTo: canvasView.bottomAnchor, constant: 4),
            lineView.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor, constant: 8),
            lineView.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor, constant: -8),
            lineView.heightAnchor.constraint(equalToConstant: 1),

            clearButton.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 24),
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    private func setupCanvas() {
        canvasView.minimumZoomScale = 1
        canvasView.maximumZoomScale = 1
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .systemBackground
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
        canvasView.isOpaque = true

        toolPicker.addObserver(canvasView)
    }

    @objc private func cancelTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onCancel()
        }
    }

    @objc private func doneTapped() {
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
        dismiss(animated: true) { [weak self] in
            self?.onDone(image)
        }
    }

    @objc private func clearTapped() {
        canvasView.drawing = PKDrawing()
    }
}
