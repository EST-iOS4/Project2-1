import UIKit

class FavoritesViewController: UIViewController {

    // MARK: - Properties
    
    // 테스트를 위한 임시 즐겨찾기 데이터
    var favoriteRoutes: [FavoriteRoute] = [
        FavoriteRoute(name: "집 -> 회사", favorites: [
            Place(name: "우리집", address: "경기도 용인시"),
            Place(name: "판교역", address: "경기도 성남시"),
            Place(name: "회사", address: "경기도 성남시")
        ]),
        FavoriteRoute(name: "주말 나들이", favorites: [
            Place(name: "스타필드", address: "경기도 하남시"),
            Place(name: "미사경정공원", address: "경기도 하남시")
        ])
    ]
    
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
        
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
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
    content.secondaryText = route.favorites.map { $0.name }.joined(separator: " → ")
    
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
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let selectedRoute = favoriteRoutes[indexPath.row]
    print("'\(selectedRoute.name)' 경로가 선택되었습니다.")
    
    // TODO: 이 경로 데이터를 경로 설정 화면으로 전달하고 화면을 전환하는 코드를 추가합니다.
    // self.tabBarController?.selectedIndex = 1 // 경로 탭(두 번째)으로 이동
  }
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    guard tableView.isEditing else {
      return nil
    }
    let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (_, _, completion) in
      self?.favoriteRoutes.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
      completion(true)
    }
    return UISwipeActionsConfiguration(actions: [deleteAction])
  }
}
