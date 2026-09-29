import UIKit

/// Shared SF Symbol placeholders shown while a crest/photo loads, or in place of one that fails
/// to load (a 404, no connectivity, an unmapped code) so a cell never renders fully blank.
enum Placeholders {
    static let teamCrest = UIImage(systemName: "shield.lefthalf.filled")

    static let playerPhoto = UIImage(systemName: "person.crop.circle.fill")
}
