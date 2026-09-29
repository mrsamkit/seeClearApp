import Foundation

enum APIError: Error, LocalizedError {
    case invalidResponse
    case http(statusCode: Int)
    case decoding(underlying: Error)
    case transport(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .http(let statusCode):
            return "The server returned an error (\(statusCode))."
        case .decoding:
            return "The data received couldn't be understood."
        case .transport:
            return "Couldn't connect. Check your network connection."
        }
    }
}

protocol FPLAPIClientProtocol: Sendable {
    func fetchBootstrap() async throws -> BootstrapResponse
}

final class URLSessionFPLAPIClient: FPLAPIClientProtocol, Sendable {
    private static let bootstrapURL = URL(string: "https://fantasy.premierleague.com/api/bootstrap-static/")!

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func fetchBootstrap() async throws -> BootstrapResponse {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: Self.bootstrapURL)
        } catch {
            throw APIError.transport(underlying: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.http(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(BootstrapResponse.self, from: data)
        } catch {
            throw APIError.decoding(underlying: error)
        }
    }
}
