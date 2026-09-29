import XCTest
@testable import SeeClear

final class FPLRepositoryTests: XCTestCase {
    private func sampleResponse() -> BootstrapResponse {
        FixtureLoader.decodeBootstrap()
    }

    func test_loadInitial_networkSucceeds_savesToCacheAndReturnsSnapshot() async throws {
        let apiClient = FakeFPLAPIClient()
        apiClient.result = .success(sampleResponse())
        let cache = FakeBootstrapCache()
        let repository = DefaultFPLRepository(apiClient: apiClient, cache: cache)

        let snapshot = try await repository.loadInitial()

        XCTAssertFalse(snapshot.teams.isEmpty)
        XCTAssertEqual(cache.savedResponses.count, 1)
    }

    func test_loadInitial_networkFails_fallsBackToCache() async throws {
        let apiClient = FakeFPLAPIClient()
        apiClient.result = .failure(FakeError("offline"))
        let cache = FakeBootstrapCache()
        cache.stored = sampleResponse()
        let repository = DefaultFPLRepository(apiClient: apiClient, cache: cache)

        let snapshot = try await repository.loadInitial()

        XCTAssertFalse(snapshot.teams.isEmpty)
    }

    func test_loadInitial_networkFailsAndNoCache_throws() async {
        let apiClient = FakeFPLAPIClient()
        apiClient.result = .failure(FakeError("offline"))
        let cache = FakeBootstrapCache()
        let repository = DefaultFPLRepository(apiClient: apiClient, cache: cache)

        await XCTAssertThrowsErrorAsync(try await repository.loadInitial())
    }

    func test_refresh_success_updatesCache() async throws {
        let apiClient = FakeFPLAPIClient()
        apiClient.result = .success(sampleResponse())
        let cache = FakeBootstrapCache()
        let repository = DefaultFPLRepository(apiClient: apiClient, cache: cache)

        _ = try await repository.refresh()

        XCTAssertEqual(cache.savedResponses.count, 1)
    }

    func test_refresh_failure_doesNotTouchCache() async {
        let apiClient = FakeFPLAPIClient()
        apiClient.result = .failure(FakeError("offline"))
        let cache = FakeBootstrapCache()
        let repository = DefaultFPLRepository(apiClient: apiClient, cache: cache)

        await XCTAssertThrowsErrorAsync(try await repository.refresh())
        XCTAssertTrue(cache.savedResponses.isEmpty)
    }
}

func XCTAssertThrowsErrorAsync(
    _ expression: @autoclosure () async throws -> some Any,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Expected error to be thrown", file: file, line: line)
    } catch {
        // expected
    }
}
