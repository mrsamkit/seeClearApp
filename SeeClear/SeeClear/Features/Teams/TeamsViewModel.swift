import Foundation

@MainActor
final class TeamsViewModel {
    private(set) var state: LoadState<FPLSnapshot> = .loading
    private(set) var isRefreshing = false
    /// Set when a pull-to-refresh fails while data is already on screen; the view controller shows it
    /// once (e.g. as a banner) then calls `acknowledgeRefreshError()`. `state` is left untouched so the
    /// existing list stays visible, per the exercise's "refresh failure keeps existing data" requirement.
    private(set) var refreshErrorMessage: String?

    /// Fired on the main actor whenever any of the observable properties above change.
    var onChange: (() -> Void)?

    private let repository: FPLRepositoryProtocol

    init(repository: FPLRepositoryProtocol) {
        self.repository = repository
    }

    func load() async {
        state = .loading
        onChange?()
        do {
            let snapshot = try await repository.loadInitial()
            state = .loaded(snapshot)
        } catch {
            state = .failed(error)
        }
        onChange?()
    }

    func refresh() async {
        guard case .loaded = state else {
            // No data on screen yet: a "refresh" in that state is just a normal (re)load.
            await load()
            return
        }
        isRefreshing = true
        onChange?()
        do {
            let snapshot = try await repository.refresh()
            state = .loaded(snapshot)
        } catch {
            refreshErrorMessage = error.localizedDescription
        }
        isRefreshing = false
        onChange?()
    }

    func acknowledgeRefreshError() {
        refreshErrorMessage = nil
    }

    var teams: [Team] {
        if case .loaded(let snapshot) = state {
            return snapshot.teams
        }
        return []
    }

    func squadViewModel(for team: Team) -> SquadViewModel? {
        guard case .loaded(let snapshot) = state else { return nil }
        return SquadViewModel(team: team, players: snapshot.players(forTeamId: team.id))
    }
}
