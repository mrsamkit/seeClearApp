import Foundation

/// Manual dependency wiring for the app. Small enough that a DI framework would be overkill.
@MainActor
struct AppDependencies {
    let repository: FPLRepositoryProtocol
    let imageLoader: ImageLoading

    static func live() -> AppDependencies {
        let apiClient = URLSessionFPLAPIClient()
        let cache = FileBootstrapCache()
        let repository = DefaultFPLRepository(apiClient: apiClient, cache: cache)
        return AppDependencies(repository: repository, imageLoader: URLSessionImageLoader())
    }

    func makeTeamsViewModel() -> TeamsViewModel {
        TeamsViewModel(repository: repository)
    }
}
