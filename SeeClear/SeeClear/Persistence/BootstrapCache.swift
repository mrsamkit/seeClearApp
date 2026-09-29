import Foundation

protocol BootstrapCacheProtocol: Sendable {
    func save(_ response: BootstrapResponse)
    func load() -> BootstrapResponse?
}

/// Persists the last successfully fetched bootstrap payload as JSON on disk, so the app can still
/// display data when launched without network connectivity.
final class FileBootstrapCache: BootstrapCacheProtocol, Sendable {
    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    /// - Parameter directory: injectable so tests never touch the app's real Caches directory.
    init(directory: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]) {
        self.fileURL = directory.appendingPathComponent("bootstrap-cache.json")
    }

    func save(_ response: BootstrapResponse) {
        guard let data = try? encoder.encode(response) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    func load() -> BootstrapResponse? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? decoder.decode(BootstrapResponse.self, from: data)
    }
}
