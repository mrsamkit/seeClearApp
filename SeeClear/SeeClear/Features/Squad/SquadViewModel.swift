import Foundation

@MainActor
final class SquadViewModel {
    struct Section {
        let position: Position
        let players: [Player]
    }

    let team: Team
    var teamName: String { team.name }

    private let allPlayers: [Player]
    private(set) var sections: [Section] = []

    var searchText: String = "" {
        didSet {
            guard searchText != oldValue else { return }
            recomputeSections()
            onChange?()
        }
    }

    var isEmpty: Bool { sections.isEmpty }

    /// Fired whenever `sections` changes (i.e. whenever `searchText` changes).
    var onChange: (() -> Void)?

    init(team: Team, players: [Player]) {
        self.team = team
        self.allPlayers = players
        recomputeSections()
    }

    private func recomputeSections() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered: [Player]
        if query.isEmpty {
            filtered = allPlayers
        } else {
            filtered = allPlayers.filter {
                $0.displayName.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            }
        }

        let grouped = Dictionary(grouping: filtered, by: \.position)
        sections = Position.displayOrder.compactMap { position in
            guard let players = grouped[position], !players.isEmpty else { return nil }
            let sorted = players.sorted { $0.totalPoints > $1.totalPoints }
            return Section(position: position, players: sorted)
        }
    }
}
