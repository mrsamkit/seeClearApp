import UIKit

protocol ImageLoading: Sendable {
    func loadImage(from url: URL) async throws -> UIImage
}

/// Fetches and in-memory caches images (team crests). Kept deliberately simple: no on-disk
/// persistence, since a missing crest just means a blank spot next time, unlike the bootstrap
/// data itself which the exercise explicitly requires to survive offline launches.
final class URLSessionImageLoader: ImageLoading, @unchecked Sendable {
    private let session: URLSession
    private let cache = NSCache<NSURL, UIImage>() // NSCache is documented thread-safe.

    init(session: URLSession = .shared) {
        self.session = session
    }

    func loadImage(from url: URL) async throws -> UIImage {
        if let cached = cache.object(forKey: url as NSURL) {
            return cached
        }
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode),
              let image = UIImage(data: data) else {
            throw APIError.invalidResponse
        }
        cache.setObject(image, forKey: url as NSURL)
        return image
    }
}
