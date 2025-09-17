//
//  TabBarController.swift
//  MapProject
//
//  Created by 강지원 on 9/17/25.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    private let favoritesVC = FavoritesViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        // 지도
        let mainVC = MainViewController()
        let nav1 = UINavigationController(rootViewController: mainVC)
        nav1.tabBarItem = UITabBarItem(title: "지도",
                                       image: UIImage(systemName: "map.fill"),
                                       tag: 0)
        
        // 검색
        let searchVC = SearchViewController()
        let nav2 = UINavigationController(rootViewController: searchVC)
        nav2.tabBarItem = UITabBarItem(title: "검색",
                                       image: UIImage(systemName: "magnifyingglass"),
                                       selectedImage: UIImage(systemName: "magnifyingglass"))
        
        // 경로 설정
        let routeListVC = RouteListViewController()
        routeListVC.delegate = favoritesVC
        let nav3 = UINavigationController(rootViewController: routeListVC)
        nav3.tabBarItem = UITabBarItem(title: "경로 설정",
                                       image: UIImage(systemName: "list.bullet"),
                                       tag: 2)
        
        // 즐겨찾기
        let nav4 = UINavigationController(rootViewController: favoritesVC)
        nav4.tabBarItem = UITabBarItem(title: "즐겨찾기",
                                       image: UIImage(systemName: "star.fill"),
                                       tag: 3)
        
        // 탭바 구성
        setViewControllers([nav1, nav2, nav3, nav4], animated: false)
        
        // appearance 설정
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .systemBackground
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance
    }
}
