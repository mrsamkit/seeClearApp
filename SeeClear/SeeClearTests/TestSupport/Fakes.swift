import Foundation
@testable import SeeClear

struct FakeError: Error, Equatable {
    let message: String
    init(_ message: String = "fake error") { self.message = message }
}

final class FakeFPLAPIClient: FPLAPIClientProtocol, @unchecked Sendable {
    var result: Result<BootstrapResponse, Error> = .failure(FakeError())
    private(set) var fetchCallCount = 0

    func fetchBootstrap() async throws -> BootstrapResponse {
        fetchCallCount += 1
        switch result {
        case .success(let response): return response
        case .failure(let error): throw error
        }
    }
}

final class FakeBootstrapCache: BootstrapCacheProtocol, @unchecked Sendable {
    private(set) var savedResponses: [BootstrapResponse] = []
    var stored: BootstrapResponse?

    func save(_ response: BootstrapResponse) {
        savedResponses.append(response)
        stored = response
    }

    func load() -> BootstrapResponse? {
        stored
    }
}

final class FakeFPLRepository: FPLRepositoryProtocol, @unchecked Sendable {
    var loadInitialResult: Result<FPLSnapshot, Error> = .failure(FakeError())
    var refreshResult: Result<FPLSnapshot, Error> = .failure(FakeError())

    func loadInitial() async throws -> FPLSnapshot {
        try loadInitialResult.get()
    }

    func refresh() async throws -> FPLSnapshot {
        try refreshResult.get()
    }
}
