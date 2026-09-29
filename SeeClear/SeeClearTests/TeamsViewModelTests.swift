import XCTest
@testable import SeeClear

@MainActor
final class TeamsViewModelTests: XCTestCase {
    private func sampleSnapshot() -> FPLSnapshot {
        BootstrapMapper.map(FixtureLoader.decodeBootstrap())
    }

    func test_load_success_transitionsToLoaded() async {
        let repository = FakeFPLRepository()
        repository.loadInitialResult = .success(sampleSnapshot())
        let viewModel = TeamsViewModel(repository: repository)

        await viewModel.load()

        guard case .loaded = viewModel.state else {
            return XCTFail("Expected .loaded state")
        }
        XCTAssertFalse(viewModel.teams.isEmpty)
    }

    func test_load_failure_transitionsToFailed() async {
        let repository = FakeFPLRepository()
        repository.loadInitialResult = .failure(FakeError("no network"))
        let viewModel = TeamsViewModel(repository: repository)

        await viewModel.load()

        guard case .failed = viewModel.state else {
            return XCTFail("Expected .failed state")
        }
    }

    func test_refresh_success_replacesLoadedData() async {
        let repository = FakeFPLRepository()
        repository.loadInitialResult = .success(sampleSnapshot())
        repository.refreshResult = .success(sampleSnapshot())
        let viewModel = TeamsViewModel(repository: repository)
        await viewModel.load()

        await viewModel.refresh()

        guard case .loaded = viewModel.state else {
            return XCTFail("Expected .loaded state")
        }
        XCTAssertFalse(viewModel.isRefreshing)
        XCTAssertNil(viewModel.refreshErrorMessage)
    }

    func test_refresh_failure_keepsExistingDataAndSetsRefreshError() async {
        let repository = FakeFPLRepository()
        repository.loadInitialResult = .success(sampleSnapshot())
        repository.refreshResult = .failure(FakeError("refresh failed"))
        let viewModel = TeamsViewModel(repository: repository)
        await viewModel.load()
        let teamsBeforeRefresh = viewModel.teams

        await viewModel.refresh()

        guard case .loaded = viewModel.state else {
            return XCTFail("Expected .loaded state to be preserved after a failed refresh")
        }
        XCTAssertEqual(viewModel.teams.map(\.id), teamsBeforeRefresh.map(\.id))
        XCTAssertNotNil(viewModel.refreshErrorMessage)
        XCTAssertFalse(viewModel.isRefreshing)
    }

    func test_acknowledgeRefreshError_clearsMessage() async {
        let repository = FakeFPLRepository()
        repository.loadInitialResult = .success(sampleSnapshot())
        repository.refreshResult = .failure(FakeError())
        let viewModel = TeamsViewModel(repository: repository)
        await viewModel.load()
        await viewModel.refresh()

        viewModel.acknowledgeRefreshError()

        XCTAssertNil(viewModel.refreshErrorMessage)
    }

    func test_squadViewModel_returnsPlayersScopedToTeam() async {
        let repository = FakeFPLRepository()
        repository.loadInitialResult = .success(sampleSnapshot())
        let viewModel = TeamsViewModel(repository: repository)
        await viewModel.load()

        let chelsea = viewModel.teams.first { $0.shortName == "CHE" }!
        let squadViewModel = viewModel.squadViewModel(for: chelsea)

        XCTAssertNotNil(squadViewModel)
        XCTAssertEqual(squadViewModel?.sections.flatMap(\.players).count, chelsea.playerCount)
    }
}
