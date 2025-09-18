import UIKit

class FavoritesViewController: UIViewController {

    // MARK: - Properties
    
    private let favoritesKey = "savedFavoriteRoutes"
    
    var favoriteRoutes: [FavoriteRoute] = []
    
  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "favoriteCell")
    return tableView
  }()
  
  private let searchController = UISearchController(searchResultsController: nil)
  private var filteredRoutes: [FavoriteRoute] = []
  private var isSearching: Bool {
    return searchController.isActive && !searchController.searchBar.text!.isEmpty
  }
    
    // MARK: - Lifecycle
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    setupTableView()
    setupSearchController()
    loadFavoritesFromUserDefaults()
    
    navigationItem.rightBarButtonItem = editButtonItem
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
      isEditing = false
  }
    
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    tableView.setEditing(editing, animated: animated)
  }
    
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadFavoritesFromUserDefaults()
  }

    
    // MARK: - Setup
    
  private func setupUI() {
    view.backgroundColor = .systemBackground
    title = "즐겨찾기"
    
    view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
    ])
  }
    
  private func setupTableView() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.allowsSelectionDuringEditing = true
  }
  
  private func setupSearchController() {
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "즐겨찾기 검색"
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
  }
    
    // MARK: - UserDefaults 저장/불러오기
    
  private func saveFavoritesToUserDefaults() {
    do {
      let data = try JSONEncoder().encode(favoriteRoutes)
      UserDefaults.standard.set(data, forKey: favoritesKey)
    } catch {
    }
  }
    
  private func loadFavoritesFromUserDefaults() {
    guard let data = UserDefaults.standard.data(forKey: favoritesKey) else { return }
    do {
      let routes = try JSONDecoder().decode([FavoriteRoute].self, from: data)
      self.favoriteRoutes = routes
      tableView.reloadData()
    } catch {
    }
  }

    // MARK: - Helper
  
  func addFavoriteRoute(_ route: FavoriteRoute) {
    if favoriteRoutes.contains(where: { $0.favorites == route.favorites }) {
      print("❌ 중복된 경로가 있어 추가하지 않습니다.")
      return
    }
    
    favoriteRoutes.append(route)
    tableView.reloadData()
    saveFavoritesToUserDefaults()
  }
}

// MARK: - RouteListViewControllerDelegate

extension FavoritesViewController: RouteListViewControllerDelegate {
  func routeListViewController(_ controller: RouteListViewController, didSaveFavoriteRoute route: FavoriteRoute) {
    if favoriteRoutes.contains(where: { $0.favorites == route.favorites }) {
      let alert = UIAlertController(title: "저장 실패", message: "이미 동일한 경로가 즐겨찾기에 존재합니다.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "확인", style: .default))
      controller.present(alert, animated: true)
    } else {
      addFavoriteRoute(route)
      self.tabBarController?.selectedIndex = 2
    }
  }
}

// MARK: - UITableView DataSource & Delegate

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return isSearching ? filteredRoutes.count : favoriteRoutes.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath)
    let route = isSearching ? filteredRoutes[indexPath.row] : favoriteRoutes[indexPath.row]
    
    var content = cell.defaultContentConfiguration()
    content.text = route.name
    
    let cleanedTitles = route.favorites.map {
      $0.title.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
    }
    content.secondaryText = cleanedTitles.joined(separator: " → ")
    
    cell.contentConfiguration = content
    cell.selectionStyle = tableView.isEditing ? .none : .default
    
    return cell
  }
  
  
  func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    guard !isSearching else { return }
    let movedRoute = favoriteRoutes.remove(at: sourceIndexPath.row)
    favoriteRoutes.insert(movedRoute, at: destinationIndexPath.row)
    saveFavoritesToUserDefaults()
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if tableView.isEditing {
      
      let routeToRename = isSearching ? filteredRoutes[indexPath.row] : favoriteRoutes[indexPath.row]
      
      let alertController = UIAlertController(title: "이름 변경",
                                              message: "새로운 경로 이름을 입력하세요.",
                                              preferredStyle: .alert)
      
      alertController.addTextField { textField in
        textField.placeholder = "경로 이름"
        textField.text = routeToRename.name
      }
      
      let saveAction = UIAlertAction(title: "저장", style: .default) { [weak self] _ in
        guard let self = self,
              let newName = alertController.textFields?.first?.text, !newName.isEmpty else { return }
        
        if let indexInOriginal = self.favoriteRoutes.firstIndex(where: { $0.name == routeToRename.name && $0.favorites == routeToRename.favorites }) {
          self.favoriteRoutes[indexInOriginal].name = newName
        }
        
        if self.isSearching, let indexInFiltered = self.filteredRoutes.firstIndex(where: { $0.name == routeToRename.name && $0.favorites == routeToRename.favorites }) {
          self.filteredRoutes[indexInFiltered].name = newName
        }
        
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        self.saveFavoritesToUserDefaults()
      }
      
      let cancelAction = UIAlertAction(title: "취소", style: .cancel)
      
      alertController.addAction(saveAction)
      alertController.addAction(cancelAction)
      
      self.present(alertController, animated: true)
      
    } else {
      
      let selectedRoute = isSearching ? filteredRoutes[indexPath.row] : favoriteRoutes[indexPath.row]
      
      RouteListManager.shared.setPlaces(selectedRoute.favorites)
      
      if let tabBarVCs = self.tabBarController?.viewControllers,
         let navController = tabBarVCs[1] as? UINavigationController,
         let routeListVC = navController.viewControllers.first as? RouteListViewController {
        routeListVC.navigationItem.title = selectedRoute.name
      }
      
      self.tabBarController?.selectedIndex = 0 // 지도화면으로 이동
    }
  }
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    guard tableView.isEditing else { return nil }
    
    let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (_, _, completion) in
      guard let self = self else {
        completion(false)
        return
      }
      
      let routeToRemove = self.isSearching ? self.filteredRoutes[indexPath.row] : self.favoriteRoutes[indexPath.row]
      
      if let indexInOriginalArray = self.favoriteRoutes.firstIndex(where: { $0.name == routeToRemove.name && $0.favorites == routeToRemove.favorites }) {
        self.favoriteRoutes.remove(at: indexInOriginalArray)
      }
      
      self.tableView.deleteRows(at: [indexPath], with: .fade)
      self.saveFavoritesToUserDefaults()
      completion(true)
    }
    return UISwipeActionsConfiguration(actions: [deleteAction])
  }
}

// MARK: - UISearchResultsUpdating

extension FavoritesViewController: UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    guard let searchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces), !searchText.isEmpty else {
      filteredRoutes.removeAll()
      tableView.reloadData()
      return
    }
    
    self.filteredRoutes = self.favoriteRoutes.filter { route in
      return route.name.lowercased().contains(searchText.lowercased())
    }
    
    self.tableView.reloadData()
  }
}
