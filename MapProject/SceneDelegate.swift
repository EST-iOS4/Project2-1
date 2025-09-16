import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  let favoritesVC = FavoritesViewController()
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    
    guard let windowScene = (scene as? UIWindowScene) else { return }
    let window = UIWindow(windowScene: windowScene)
    
    let tabBarController = UITabBarController()
    
    let mainVC = MainViewController()
    mainVC.tabBarItem = UITabBarItem(title: "지도", image: UIImage(systemName: "map.fill"), tag: 0)
    
    let routeListVC = RouteListViewController()
    routeListVC.tabBarItem = UITabBarItem(title: "경로 설정", image: UIImage(systemName: "list.bullet"), tag: 1)
    
    favoritesVC.tabBarItem = UITabBarItem(title: "즐겨찾기", image: UIImage(systemName: "star.fill"), tag: 2)
    
    routeListVC.delegate = favoritesVC
    
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
}
