import UIKit
import Foundation

// MARK: - Delegate 정의
protocol RouteListViewControllerDelegate: AnyObject {
    func routeListViewController(_ controller: RouteListViewController, didSaveFavoriteRoute route: FavoriteRoute)
}

class RouteListViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: RouteListViewControllerDelegate? // ✅ delegate 선언
    
    private var places: [PlaceModel] {
        return RouteListManager.shared.selectedPlaces
    }
    
    private let tableView = UITableView()
    
    private lazy var resetButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "trash"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(resetButtonTapped))
        button.tintColor = .red
        return button
    }()
    
    private var favoritesButton: UIBarButtonItem?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()

        favoritesButton = UIBarButtonItem(image: UIImage(systemName: "star"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(favoritesButtonTapped))

        if let favButton = favoritesButton {
            navigationItem.setLeftBarButtonItems([favButton], animated: false)
        }
        navigationItem.rightBarButtonItem = editButtonItem

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteListUpdate),
                                               name: .routeListDidUpdate,
                                               object: nil)
    }

    @objc private func handleRouteListUpdate() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }


    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        
        if editing {
            navigationItem.setLeftBarButtonItems([resetButton], animated: animated)
        } else {
            if let favButton = favoritesButton {
                navigationItem.setLeftBarButtonItems([favButton], animated: animated)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func favoritesButtonTapped() {
        let alertController = UIAlertController(title: "경로 저장",
                                                message: "이 경로의 이름을 입력하세요.",
                                                preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "예: 우리집에서 회사까지"
        }
        
        let saveAction = UIAlertAction(title: "저장", style: .default) { _ in
            guard let routeName = alertController.textFields?.first?.text,
                  !routeName.isEmpty else {
                print("경로 이름이 입력되지 않았습니다.")
                return
            }
            self.saveRoute(withName: routeName)
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    @objc private func resetButtonTapped() {
        let alertController = UIAlertController(title: "경로 초기화",
                                                message: "정말로 모든 경로를 삭제하시겠습니까?",
                                                preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            RouteListManager.shared.clear()

            // ✅ 직접 테이블 뷰 리로드 (안전하게 메인 큐에서)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        alertController.addAction(deleteAction)
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))

        present(alertController, animated: true)
    }

    
    private func saveRoute(withName name: String) {
        let favoriteRoute = FavoriteRoute(name: name, favorites: places)
        delegate?.routeListViewController(self, didSaveFavoriteRoute: favoriteRoute) // ✅ delegate 호출
        print("✅ 즐겨찾기 '\(name)' 저장됨.")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "경로 설정"
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "placeCell")
    }
}

// MARK: - Notification 이름
extension Notification.Name {
    static let routeListDidUpdate = Notification.Name("routeListDidUpdate")
}

// MARK: - TableView DataSource & Delegate
extension RouteListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)
        let place = places[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = place.title.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
        content.secondaryText = place.roadAddress.isEmpty ? place.address : place.roadAddress
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var current = RouteListManager.shared.selectedPlaces
        let movedPlace = current.remove(at: sourceIndexPath.row)
        current.insert(movedPlace, at: destinationIndexPath.row)
        RouteListManager.shared.setPlaces(current)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard tableView.isEditing else { return nil }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { _, _, completion in
            let target = self.places[indexPath.row]
            RouteListManager.shared.remove(target)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
