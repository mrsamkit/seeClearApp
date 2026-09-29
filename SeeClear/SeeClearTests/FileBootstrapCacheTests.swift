import XCTest
@testable import SeeClear

final class FileBootstrapCacheTests: XCTestCase {
    private var tempDirectory: URL!

    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }

    func test_load_withNothingSaved_returnsNil() {
        let cache = FileBootstrapCache(directory: tempDirectory)
        XCTAssertNil(cache.load())
    }

    func test_saveThenLoad_roundTrips() {
        let cache = FileBootstrapCache(directory: tempDirectory)
        let response = FixtureLoader.decodeBootstrap()

        cache.save(response)

        XCTAssertEqual(cache.load(), response)
    }

    func test_load_withCorruptedFile_returnsNilRatherThanCrashing() throws {
        let cache = FileBootstrapCache(directory: tempDirectory)
        let fileURL = tempDirectory.appendingPathComponent("bootstrap-cache.json")
        try "not valid json".data(using: .utf8)?.write(to: fileURL)

        XCTAssertNil(cache.load())
    }
}
