import Foundation

/// A loaded, UI-ready snapshot of teams and players.
struct FPLSnapshot: Equatable {
    let teams: [Team]
    let players: [Player]

    func players(forTeamId teamId: Int) -> [Player] {
        players.filter { $0.teamId == teamId }
    }
}

/// Pure transformation from wire-format DTOs to domain models. Free of I/O so it's trivially unit-testable.
enum BootstrapMapper {
    static func map(_ response: BootstrapResponse) -> FPLSnapshot {
        let players: [Player] = response.elements.compactMap { element in
            guard let position = Position(rawValue: element.elementType) else {
                // Unmapped element types (e.g. a future "Manager" slot) are excluded rather than
                // crashing or mis-categorizing the player.
                return nil
            }
            return Player(
                id: element.id,
                teamId: element.team,
                displayName: element.webName,
                position: position,
                price: Double(element.nowCost) / 10.0,
                totalPoints: element.totalPoints,
                code: element.code
            )
        }

        let countsByTeam = Dictionary(grouping: players, by: \.teamId).mapValues(\.count)

        let teams: [Team] = response.teams.map { teamDTO in
            Team(
                id: teamDTO.id,
                name: teamDTO.name,
                shortName: teamDTO.shortName,
                playerCount: countsByTeam[teamDTO.id] ?? 0,
                code: teamDTO.code
            )
        }

        return FPLSnapshot(teams: teams, players: players)
    }
}
