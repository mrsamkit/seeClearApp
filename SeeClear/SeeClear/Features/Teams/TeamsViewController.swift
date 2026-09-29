import UIKit

final class TeamsViewController: UIViewController {
    private let viewModel: TeamsViewModel
    private let imageLoader: ImageLoading

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let statusOverlay = StatusOverlayView()
    private let refreshControl = UIRefreshControl()
    private var loadTask: Task<Void, Never>?

    init(viewModel: TeamsViewModel, imageLoader: ImageLoading) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    deinit {
        loadTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Premier League"
        view.backgroundColor = .systemBackground

        setUpTableView()
        setUpStatusOverlay()

        viewModel.onChange = { [weak self] in
            self?.render()
        }

        loadTask = Task { [weak self] in
            await self?.viewModel.load()
        }
    }

    private func setUpTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TeamCell.self, forCellReuseIdentifier: TeamCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        refreshControl.addTarget(self, action: #selector(pulledToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
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
        statusOverlay.onRetry = { [weak self] in
            self?.loadTask = Task { [weak self] in
                await self?.viewModel.load()
            }
        }
        view.addSubview(statusOverlay)
        NSLayoutConstraint.activate([
            statusOverlay.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            statusOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func pulledToRefresh() {
        Task { [weak self] in
            await self?.viewModel.refresh()
        }
    }

    private func render() {
        switch viewModel.state {
        case .loading:
            statusOverlay.showLoading()
        case .failed(let error):
            statusOverlay.showError(message: error.localizedDescription)
        case .loaded:
            if viewModel.teams.isEmpty {
                statusOverlay.showEmpty(message: "No teams available.")
            } else {
                statusOverlay.hide()
            }
            tableView.reloadData()
        }

        if !viewModel.isRefreshing, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }

        if let message = viewModel.refreshErrorMessage {
            showRefreshErrorBanner(message: message)
            viewModel.acknowledgeRefreshError()
        }
    }

    private func showRefreshErrorBanner(message: String) {
        let alert = UIAlertController(title: "Refresh failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension TeamsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.teams.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TeamCell.reuseIdentifier, for: indexPath) as! TeamCell
        cell.configure(with: viewModel.teams[indexPath.row], imageLoader: imageLoader)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let team = viewModel.teams[indexPath.row]
        guard let squadViewModel = viewModel.squadViewModel(for: team) else { return }
        let squadViewController = SquadViewController(viewModel: squadViewModel, imageLoader: imageLoader)
        navigationController?.pushViewController(squadViewController, animated: true)
    }
}
