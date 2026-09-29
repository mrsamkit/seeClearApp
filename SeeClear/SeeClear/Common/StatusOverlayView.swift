import UIKit

/// A full-bounds overlay for the three non-content states a list screen can be in: loading, error
/// (with retry), and empty. Shown/hidden by the owning view controller over its table view so the
/// table's own scroll/refresh-control behaviour doesn't need to be duplicated per screen.
final class StatusOverlayView: UIView {
    var onRetry: (() -> Void)?

    private let spinner = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    private func setUpViews() {
        backgroundColor = .systemBackground

        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.textColor = .secondaryLabel

        retryButton.setTitle("Retry", for: .normal)
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(spinner)
        stack.addArrangedSubview(messageLabel)
        stack.addArrangedSubview(retryButton)
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    @objc private func retryTapped() {
        onRetry?()
    }

    func showLoading() {
        isHidden = false
        spinner.startAnimating()
        messageLabel.isHidden = true
        retryButton.isHidden = true
    }

    func showError(message: String) {
        isHidden = false
        spinner.stopAnimating()
        messageLabel.text = message
        messageLabel.isHidden = false
        retryButton.isHidden = false
    }

    func showEmpty(message: String) {
        isHidden = false
        spinner.stopAnimating()
        messageLabel.text = message
        messageLabel.isHidden = false
        retryButton.isHidden = true
    }

    func hide() {
        isHidden = true
        spinner.stopAnimating()
    }
}
