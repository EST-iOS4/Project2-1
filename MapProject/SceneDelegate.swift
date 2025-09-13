import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // ✅ FavoritesVC 인스턴스를 전역 프로퍼티로 저장
    let favoritesVC = FavoritesViewController()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)

        let tabBarController = UITabBarController()

        // ✅ 각 VC 생성
        let mainVC = ViewController()
        mainVC.tabBarItem = UITabBarItem(title: "지도", image: UIImage(systemName: "map.fill"), tag: 0)

        let routeListVC = RouteListViewController()
        routeListVC.tabBarItem = UITabBarItem(title: "경로", image: UIImage(systemName: "list.bullet"), tag: 1)

        // ✅ FavoritesVC는 위에서 만든 인스턴스를 사용
        favoritesVC.tabBarItem = UITabBarItem(title: "즐겨찾기", image: UIImage(systemName: "star.fill"), tag: 2)

        // ✅ 필요한 경우 routeListVC에 delegate 연결
        routeListVC.delegate = favoritesVC

        // ✅ UINavigationController로 감싸기 (탭마다 내비게이션 사용)
        let nav1 = UINavigationController(rootViewController: mainVC)
        let nav2 = UINavigationController(rootViewController: routeListVC)
        let nav3 = UINavigationController(rootViewController: favoritesVC)

        tabBarController.setViewControllers([nav1, nav2, nav3], animated: false)

        // ✅ 탭바 appearance 설정
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .systemBackground

        tabBarController.tabBar.standardAppearance = tabBarAppearance
        tabBarController.tabBar.scrollEdgeAppearance = tabBarAppearance

        // ✅ 탭바를 rootViewController로 설정
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        self.window = window
    }
}
