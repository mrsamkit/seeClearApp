import XCTest
@testable import SeeClear

final class TeamCrestURLTests: XCTestCase {
    func test_crestURL_isBuiltFromTeamCode() {
        let team = Team(id: 1, name: "Arsenal", shortName: "ARS", playerCount: 25, code: 3)
        XCTAssertEqual(team.crestURL?.absoluteString, "https://resources.premierleague.com/premierleague/badges/70/t3.png")
    }

    func test_photoURL_isBuiltFromPlayerCode() {
        let player = Player(id: 1, teamId: 1, displayName: "Raya", position: .goalkeeper, price: 5.5, totalPoints: 120, code: 154561)
        XCTAssertEqual(
            player.photoURL?.absoluteString,
            "https://resources.premierleague.com/premierleague/photos/players/110x140/p154561.png"
        )
    }
}
