import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let dependencies = AppDependencies.live()
        let teamsViewController = TeamsViewController(
            viewModel: dependencies.makeTeamsViewModel(),
            imageLoader: dependencies.imageLoader
        )
        let navigationController = UINavigationController(rootViewController: teamsViewController)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }
}
