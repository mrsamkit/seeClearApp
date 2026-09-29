import Foundation

/// A player's on-pitch position, derived from the FPL `element_type` id.
enum Position: Int, CaseIterable, Codable, Comparable {
    case goalkeeper = 1
    case defender = 2
    case midfielder = 3
    case forward = 4

    /// Fixed display order for squad sections: GKP, DEF, MID, FWD.
    static let displayOrder: [Position] = [.goalkeeper, .defender, .midfielder, .forward]

    var sectionTitle: String {
        switch self {
        case .goalkeeper: return "Goalkeepers"
        case .defender: return "Defenders"
        case .midfielder: return "Midfielders"
        case .forward: return "Forwards"
        }
    }

    var shortName: String {
        switch self {
        case .goalkeeper: return "GKP"
        case .defender: return "DEF"
        case .midfielder: return "MID"
        case .forward: return "FWD"
        }
    }

    static func < (lhs: Position, rhs: Position) -> Bool {
        let order = displayOrder
        guard let l = order.firstIndex(of: lhs), let r = order.firstIndex(of: rhs) else { return false }
        return l < r
    }
}
