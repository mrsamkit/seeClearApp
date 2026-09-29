import Foundation

/// Domain model for a player, independent of the FPL wire format.
struct Player: Identifiable, Equatable {
    let id: Int
    let teamId: Int
    let displayName: String
    let position: Position
    /// Price in millions of £ (FPL's `now_cost` is in tenths, e.g. 55 -> 5.5).
    let price: Double
    let totalPoints: Int
    /// FPL's Opta player code, used to build the photo URL (not the same as `id`).
    let code: Int

    /// The Premier League's own player photo CDN, keyed by `code`. Optional so a missing/renamed
    /// asset degrades to "no photo" rather than a crash.
    var photoURL: URL? {
        URL(string: "https://resources.premierleague.com/premierleague/photos/players/110x140/p\(code).png")
    }
}
