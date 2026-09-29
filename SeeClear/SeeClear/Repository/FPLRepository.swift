import Foundation

protocol FPLRepositoryProtocol: Sendable {
    /// Used for the very first load. Falls back to cached data when the network fails, so a launch
    /// without connectivity can still show the last known snapshot. Throws only when the network
    /// fails *and* there's no cache to fall back to.
    func loadInitial() async throws -> FPLSnapshot

    /// Used for pull-to-refresh. Always hits the network and throws on failure without touching the
    /// cache; the caller is responsible for keeping previously-loaded data on screen.
    func refresh() async throws -> FPLSnapshot
}

final class DefaultFPLRepository: FPLRepositoryProtocol, Sendable {
    private let apiClient: FPLAPIClientProtocol
    private let cache: BootstrapCacheProtocol

    init(apiClient: FPLAPIClientProtocol, cache: BootstrapCacheProtocol) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func loadInitial() async throws -> FPLSnapshot {
        do {
            let response = try await apiClient.fetchBootstrap()
            cache.save(response)
            return BootstrapMapper.map(response)
        } catch {
            if let cached = cache.load() {
                return BootstrapMapper.map(cached)
            }
            throw error
        }
    }

    func refresh() async throws -> FPLSnapshot {
        let response = try await apiClient.fetchBootstrap()
        cache.save(response)
        return BootstrapMapper.map(response)
    }
}
