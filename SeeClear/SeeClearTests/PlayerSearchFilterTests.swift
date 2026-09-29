import XCTest
@testable import SeeClear

@MainActor
final class PlayerSearchFilterTests: XCTestCase {
    private func makeTeam() -> Team {
        Team(id: 1, name: "Arsenal", shortName: "ARS", playerCount: 5, code: 3)
    }

    private func makePlayers() -> [Player] {
        [
            Player(id: 1, teamId: 1, displayName: "Raya", position: .goalkeeper, price: 5.0, totalPoints: 120, code: 101),
            Player(id: 2, teamId: 1, displayName: "Saliba", position: .defender, price: 5.5, totalPoints: 110, code: 102),
            Player(id: 3, teamId: 1, displayName: "Odegaard", position: .midfielder, price: 8.5, totalPoints: 150, code: 103),
            Player(id: 4, teamId: 1, displayName: "Rice", position: .midfielder, price: 6.5, totalPoints: 140, code: 104),
            Player(id: 5, teamId: 1, displayName: "Saka", position: .forward, price: 9.0, totalPoints: 200, code: 105)
        ]
    }

    func test_noSearch_groupsByPositionInDisplayOrderSortedByPointsDescending() {
        let viewModel = SquadViewModel(team: makeTeam(), players: makePlayers())

        XCTAssertEqual(viewModel.sections.map(\.position), [.goalkeeper, .defender, .midfielder, .forward])
        XCTAssertEqual(viewModel.sections.first { $0.position == .midfielder }?.players.map(\.displayName), ["Odegaard", "Rice"])
    }

    func test_search_isCaseInsensitiveSubstringMatch() {
        let viewModel = SquadViewModel(team: makeTeam(), players: makePlayers())

        viewModel.searchText = "sak"
        XCTAssertEqual(viewModel.sections.flatMap(\.players).map(\.displayName), ["Saka"])
    }

    func test_search_withNoMatches_producesEmptySections() {
        let viewModel = SquadViewModel(team: makeTeam(), players: makePlayers())

        viewModel.searchText = "zzz-nobody"
        XCTAssertTrue(viewModel.sections.isEmpty)
        XCTAssertTrue(viewModel.isEmpty)
    }

    func test_clearingSearch_restoresFullSquad() {
        let viewModel = SquadViewModel(team: makeTeam(), players: makePlayers())

        viewModel.searchText = "saka"
        viewModel.searchText = ""
        XCTAssertEqual(viewModel.sections.flatMap(\.players).count, 5)
    }

    func test_onChange_firesWhenSearchTextChanges() {
        let viewModel = SquadViewModel(team: makeTeam(), players: makePlayers())
        var changeCount = 0
        viewModel.onChange = { changeCount += 1 }

        viewModel.searchText = "s"
        viewModel.searchText = "s" // unchanged, should not re-fire

        XCTAssertEqual(changeCount, 1)
    }
}
