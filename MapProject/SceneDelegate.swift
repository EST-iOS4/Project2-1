import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    let window = UIWindow(windowScene: windowScene)
    
    let tabBarController = UITabBarController()
    
    let mainVC = ViewController()
    let routeListVC = RouteListViewController()
    let favoritesVC = FavoritesViewController()
    
    mainVC.tabBarItem = UITabBarItem(title: "지도", image: UIImage(systemName: "map.fill"), tag: 0)
    routeListVC.tabBarItem = UITabBarItem(title: "경로", image: UIImage(systemName: "list.bullet"), tag: 1)
    favoritesVC.tabBarItem = UITabBarItem(title: "즐겨찾기", image: UIImage(systemName: "star.fill"), tag: 2)
    
    let nav1 = UINavigationController(rootViewController: mainVC)
    let nav2 = UINavigationController(rootViewController: routeListVC)
    let nav3 = UINavigationController(rootViewController: favoritesVC)
    
    tabBarController.setViewControllers([nav1, nav2, nav3], animated: false)
    
    let tabBarAppearance = UITabBarAppearance()
    
    tabBarAppearance.configureWithOpaqueBackground()
    tabBarAppearance.backgroundColor = .systemBackground
    
    tabBarController.tabBar.standardAppearance = tabBarAppearance
    tabBarController.tabBar.scrollEdgeAppearance = tabBarAppearance
    
    window.rootViewController = tabBarController
    window.makeKeyAndVisible()
    self.window = window
  }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

