import UIKit

final class SquadViewController: UIViewController {
    private let viewModel: SquadViewModel
    private let imageLoader: ImageLoading

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let statusOverlay = StatusOverlayView()
    private let searchController = UISearchController(searchResultsController: nil)
    private var crestLoadTask: Task<Void, Never>?

    init(viewModel: SquadViewModel, imageLoader: ImageLoading) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    deinit {
        crestLoadTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setUpTitleView()
        setUpTableView()
        setUpStatusOverlay()
        setUpSearch()

        viewModel.onChange = { [weak self] in
            self?.render()
        }
        render()
    }

    private func setUpTitleView() {
        let crestImageView = UIImageView()
        crestImageView.image = Placeholders.teamCrest
        crestImageView.tintColor = .tertiaryLabel
        crestImageView.contentMode = .scaleAspectFit
        crestImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            crestImageView.widthAnchor.constraint(equalToConstant: 24),
            crestImageView.heightAnchor.constraint(equalToConstant: 24)
        ])

        let nameLabel = UILabel()
        nameLabel.text = viewModel.teamName
        nameLabel.font = .preferredFont(forTextStyle: .headline)

        let stack = UIStackView(arrangedSubviews: [crestImageView, nameLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        navigationItem.titleView = stack

        guard let url = viewModel.team.crestURL else { return }
        crestLoadTask = Task { [weak crestImageView, imageLoader] in
            guard let image = try? await imageLoader.loadImage(from: url), !Task.isCancelled else { return }
            crestImageView?.image = image
        }
    }

    private func setUpTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 54
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setUpStatusOverlay() {
        statusOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusOverlay)
        NSLayoutConstraint.activate([
            statusOverlay.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            statusOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setUpSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search players"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func render() {
        tableView.reloadData()
        if viewModel.isEmpty {
            let message = viewModel.searchText.isEmpty
                ? "No players found for this team."
                : "No players match \u{201C}\(viewModel.searchText)\u{201D}."
            statusOverlay.showEmpty(message: message)
        } else {
            statusOverlay.hide()
        }
    }
}

extension SquadViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sections[section].players.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.sections[section].position.sectionTitle
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlayerCell.reuseIdentifier, for: indexPath) as! PlayerCell
        cell.configure(with: viewModel.sections[indexPath.section].players[indexPath.row], imageLoader: imageLoader)
        return cell
    }
}

extension SquadViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchText = searchController.searchBar.text ?? ""
    }
}
