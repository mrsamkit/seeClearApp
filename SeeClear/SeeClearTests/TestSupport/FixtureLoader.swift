import Foundation
@testable import SeeClear

private final class FixtureLoaderMarker {}

enum FixtureLoader {
    static func data(named name: String, extension ext: String = "json") -> Data {
        let bundle = Bundle(for: FixtureLoaderMarker.self)
        guard let url = bundle.url(forResource: name, withExtension: ext) else {
            fatalError("Missing fixture \(name).\(ext) in test bundle")
        }
        return try! Data(contentsOf: url) // swiftlint:disable:this force_try
    }

    static func decodeBootstrap(named name: String = "bootstrap_sample") -> BootstrapResponse {
        try! JSONDecoder().decode(BootstrapResponse.self, from: data(named: name))
    }
}
