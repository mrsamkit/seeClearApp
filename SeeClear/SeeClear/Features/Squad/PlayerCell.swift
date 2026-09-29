import UIKit

final class PlayerCell: UITableViewCell {
    static let reuseIdentifier = "PlayerCell"

    private let photoImageView = UIImageView()
    private let nameLabel = UILabel()
    private let positionLabel = UILabel()
    private let priceLabel = UILabel()
    private let pointsLabel = UILabel()
    private var imageLoadTask: Task<Void, Never>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        photoImageView.image = Placeholders.playerPhoto
        photoImageView.contentMode = .scaleAspectFill
    }

    private func setUpViews() {
        photoImageView.image = Placeholders.playerPhoto
        photoImageView.tintColor = .tertiaryLabel
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.backgroundColor = .secondarySystemBackground
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoImageView.widthAnchor.constraint(equalToConstant: 40),
            photoImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        photoImageView.layer.cornerRadius = 20

        nameLabel.font = .preferredFont(forTextStyle: .body)

        positionLabel.font = .preferredFont(forTextStyle: .caption1)
        positionLabel.textColor = .secondaryLabel

        priceLabel.font = .preferredFont(forTextStyle: .subheadline)
        priceLabel.textColor = .secondaryLabel
        priceLabel.textAlignment = .right
        priceLabel.setContentHuggingPriority(.required, for: .horizontal)

        pointsLabel.font = .preferredFont(forTextStyle: .subheadline)
        pointsLabel.textAlignment = .right
        pointsLabel.setContentHuggingPriority(.required, for: .horizontal)

        let nameStack = UIStackView(arrangedSubviews: [nameLabel, positionLabel])
        nameStack.axis = .vertical
        nameStack.spacing = 2

        let trailingStack = UIStackView(arrangedSubviews: [priceLabel, pointsLabel])
        trailingStack.axis = .vertical
        trailingStack.spacing = 2
        trailingStack.alignment = .trailing

        let rowStack = UIStackView(arrangedSubviews: [photoImageView, nameStack, trailingStack])
        rowStack.axis = .horizontal
        rowStack.alignment = .center
        rowStack.spacing = 12
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rowStack)

        NSLayoutConstraint.activate([
            rowStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            rowStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            rowStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 6),
            rowStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor, constant: -6)
        ])
    }

    func configure(with player: Player, imageLoader: ImageLoading) {
        nameLabel.text = player.displayName
        positionLabel.text = player.position.shortName
        priceLabel.text = Formatting.price(player.price)
        pointsLabel.text = Formatting.points(player.totalPoints)

        imageLoadTask?.cancel()
        photoImageView.image = Placeholders.playerPhoto
        guard let url = player.photoURL else { return }
        imageLoadTask = Task { [weak self] in
            guard let image = try? await imageLoader.loadImage(from: url), !Task.isCancelled else { return }
            self?.photoImageView.image = image
        }
    }
}
