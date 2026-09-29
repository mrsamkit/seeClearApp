import Foundation

enum Formatting {
    static func price(_ millions: Double) -> String {
        String(format: "£%.1fm", millions)
    }

    static func points(_ points: Int) -> String {
        points == 1 ? "1 pt" : "\(points) pts"
    }
}
