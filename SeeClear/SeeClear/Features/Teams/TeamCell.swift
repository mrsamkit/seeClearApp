import UIKit

final class TeamCell: UITableViewCell {
    static let reuseIdentifier = "TeamCell"

    private let crestImageView = UIImageView()
    private let nameLabel = UILabel()
    private let detailLabel = UILabel()
    private var imageLoadTask: Task<Void, Never>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        crestImageView.image = Placeholders.teamCrest
    }

    private func setUpViews() {
        accessoryType = .disclosureIndicator

        crestImageView.image = Placeholders.teamCrest
        crestImageView.tintColor = .tertiaryLabel
        crestImageView.contentMode = .scaleAspectFit
        crestImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            crestImageView.widthAnchor.constraint(equalToConstant: 36),
            crestImageView.heightAnchor.constraint(equalToConstant: 36)
        ])

        nameLabel.font = .preferredFont(forTextStyle: .headline)
        detailLabel.font = .preferredFont(forTextStyle: .subheadline)
        detailLabel.textColor = .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [nameLabel, detailLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let rowStack = UIStackView(arrangedSubviews: [crestImageView, textStack])
        rowStack.axis = .horizontal
        rowStack.alignment = .center
        rowStack.spacing = 12
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rowStack)

        NSLayoutConstraint.activate([
            rowStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            rowStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            rowStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 8),
            rowStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor, constant: -8)
        ])
    }

    func configure(with team: Team, imageLoader: ImageLoading) {
        nameLabel.text = team.name
        let playerWord = team.playerCount == 1 ? "player" : "players"
        detailLabel.text = "\(team.shortName) · \(team.playerCount) \(playerWord)"

        imageLoadTask?.cancel()
        crestImageView.image = Placeholders.teamCrest
        guard let url = team.crestURL else { return }
        imageLoadTask = Task { [weak self] in
            guard let image = try? await imageLoader.loadImage(from: url), !Task.isCancelled else { return }
            self?.crestImageView.image = image
        }
    }
}
