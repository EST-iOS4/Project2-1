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
    
    // MARK: - Lifecycle
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    setupTableView()
    loadFavoritesFromUserDefaults()
    
    navigationItem.rightBarButtonItem = editButtonItem
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print("📌 FavoritesViewController 화면 표시됨")
    print("🔢 즐겨찾기 개수: \(favoriteRoutes.count)")
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
  }
    
    // MARK: - UserDefaults 저장/불러오기
    
  private func saveFavoritesToUserDefaults() {
    do {
      let data = try JSONEncoder().encode(favoriteRoutes)
      UserDefaults.standard.set(data, forKey: favoritesKey)
      print("✅ 즐겨찾기 저장 완료")
    } catch {
      print("❌ 즐겨찾기 저장 실패: \(error.localizedDescription)")
    }
  }
    
  private func loadFavoritesFromUserDefaults() {
    guard let data = UserDefaults.standard.data(forKey: favoritesKey) else { return }
    do {
      let routes = try JSONDecoder().decode([FavoriteRoute].self, from: data)
      self.favoriteRoutes = routes
      tableView.reloadData()
      print("✅ 즐겨찾기 불러오기 완료")
    } catch {
      print("❌ 즐겨찾기 불러오기 실패: \(error.localizedDescription)")
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
    return favoriteRoutes.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath)
    let route = favoriteRoutes[indexPath.row]
    
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
    let movedRoute = favoriteRoutes.remove(at: sourceIndexPath.row)
    favoriteRoutes.insert(movedRoute, at: destinationIndexPath.row)
    saveFavoritesToUserDefaults()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let selectedRoute = favoriteRoutes[indexPath.row]
    print("'\(selectedRoute.name)' 경로가 선택되었습니다.")
    
    RouteListManager.shared.setPlaces(selectedRoute.favorites)
    self.tabBarController?.selectedIndex = 1
  }
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    guard tableView.isEditing else { return nil }
    
    let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (_, _, completion) in
      self?.favoriteRoutes.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
      self?.saveFavoritesToUserDefaults()
      completion(true)
    }
    return UISwipeActionsConfiguration(actions: [deleteAction])
  }
}
