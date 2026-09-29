import Foundation

/// Wire-format DTOs for `GET /api/bootstrap-static/`. Kept separate from the domain models
/// (`Team`, `Player`) so unrelated fields and any FPL JSON-shape changes don't leak into the UI layer.
/// Only the fields we actually use are declared; `Codable` ignores the rest of the payload.
struct BootstrapResponse: Codable, Equatable {
    let teams: [TeamDTO]
    let elements: [ElementDTO]
}

struct TeamDTO: Codable, Equatable {
    let id: Int
    let name: String
    let shortName: String
    /// Opta team code used to build the crest image URL (see `Team.crestURL`).
    let code: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case shortName = "short_name"
        case code
    }
}

struct ElementDTO: Codable, Equatable {
    let id: Int
    let team: Int
    let webName: String
    /// Raw FPL position id. 1=GKP, 2=DEF, 3=MID, 4=FWD (newer ids, e.g. 5=Manager, are unmapped
    /// and filtered out by `BootstrapMapper`).
    let elementType: Int
    /// Price in tenths of £m, e.g. 55 -> £5.5m.
    let nowCost: Int
    let totalPoints: Int
    /// Opta player code used to build the photo URL (see `Player.photoURL`).
    let code: Int

    enum CodingKeys: String, CodingKey {
        case id
        case team
        case webName = "web_name"
        case elementType = "element_type"
        case nowCost = "now_cost"
        case totalPoints = "total_points"
        case code
    }
}
