import Foundation

/// Domain model for a Premier League team, independent of the FPL wire format.
struct Team: Identifiable, Equatable {
    let id: Int
    let name: String
    let shortName: String
    let playerCount: Int
    /// FPL's Opta team code, used to build the crest URL (not the same as `id`).
    let code: Int

    /// The Premier League's own badge CDN, keyed by `code`. Optional so a future change in the
    /// asset host or a malformed code degrades to "no crest" rather than a crash.
    var crestURL: URL? {
        URL(string: "https://resources.premierleague.com/premierleague/badges/70/t\(code).png")
    }
}
