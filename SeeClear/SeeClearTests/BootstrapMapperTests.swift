import XCTest
@testable import SeeClear

final class BootstrapMapperTests: XCTestCase {
    func test_decodesFixture_withoutThrowing() {
        _ = FixtureLoader.decodeBootstrap()
    }

    func test_map_buildsTeamsWithCorrectPlayerCounts() {
        let response = FixtureLoader.decodeBootstrap()
        let snapshot = BootstrapMapper.map(response)

        let arsenal = snapshot.teams.first { $0.id == 1 }
        let chelsea = snapshot.teams.first { $0.id == 2 }

        XCTAssertEqual(arsenal?.name, "Arsenal")
        XCTAssertEqual(arsenal?.shortName, "ARS")
        // 5 valid Arsenal players in the fixture (Raya, Saliba, Odegaard, Rice, Saka) -
        // the element_type 5 "MysteryManager" is unmapped and excluded.
        XCTAssertEqual(arsenal?.playerCount, 5)
        XCTAssertEqual(chelsea?.playerCount, 2)
    }

    func test_map_assignsCorrectPositionAndPrice() {
        let response = FixtureLoader.decodeBootstrap()
        let snapshot = BootstrapMapper.map(response)

        let saka = snapshot.players.first { $0.displayName == "Saka" }
        XCTAssertEqual(saka?.position, .forward)
        XCTAssertEqual(saka?.price, 9.0)
        XCTAssertEqual(saka?.totalPoints, 200)
    }

    func test_map_excludesPlayersWithUnmappedPosition() {
        let response = FixtureLoader.decodeBootstrap()
        let snapshot = BootstrapMapper.map(response)

        XCTAssertFalse(snapshot.players.contains { $0.displayName == "MysteryManager" })
    }

    func test_snapshot_playersForTeamId_filtersCorrectly() {
        let response = FixtureLoader.decodeBootstrap()
        let snapshot = BootstrapMapper.map(response)

        let chelseaPlayers = snapshot.players(forTeamId: 2)
        XCTAssertEqual(Set(chelseaPlayers.map(\.displayName)), ["Sanchez", "James"])
    }
}
