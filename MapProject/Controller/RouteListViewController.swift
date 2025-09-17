import UIKit
import Foundation

protocol RouteListViewControllerDelegate: AnyObject { // 선택 이후 저장된 즐겨찾기 경로들을 즐겨찾기 탭으로 전달
    func routeListViewController(_ controller: RouteListViewController, didSaveFavoriteRoute route: FavoriteRoute)
}

class RouteListViewController: UIViewController {
    
    weak var delegate: RouteListViewControllerDelegate?
    
    private var places: [PlaceModel] { // 경로 설정 탭에서 선택된 장소들 불러오기
        return RouteListManager.shared.selectedPlaces
    }
    
    private let tableView = UITableView()
    
    private var favoritesButton: UIBarButtonItem? // 즐겨찾기 등록 버튼
    
    private lazy var resetButton: UIBarButtonItem = { // 초기화 버튼
        let button = UIBarButtonItem(image: UIImage(systemName: "trash"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(resetButtonTapped))
        button.tintColor = .red
        return button
    }()
    
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
        
        navigationItem.rightBarButtonItem = editButtonItem // 기본 제공 edit 버튼 사용
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(editRouteListUpdate),
                                               name: .routeListDidUpdate,
                                               object: nil)
    }
    
    @objc private func editRouteListUpdate() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        
        if editing {
            // 편집모드 진입 시: 초기화 버튼 표시
            navigationItem.setLeftBarButtonItems([resetButton], animated: animated)
        } else {
            // 편집모드 종료 시: 즐겨찾기 버튼 복구
            if let favButton = favoritesButton {
                navigationItem.setLeftBarButtonItems([favButton], animated: animated)
            }
        }
    }
   
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
    
    /// 경로 초기화 다이얼로그 표시
    @objc private func resetButtonTapped() {
        let alertController = UIAlertController(title: "경로 초기화",
                                                message: "정말로 모든 경로를 삭제하시겠습니까?",
                                                preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            RouteListManager.shared.clear()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.setEditing(false, animated: true)
                self.navigationItem.title = "경로 설정"
            }
        }
        
        alertController.addAction(deleteAction)
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    
    /// 경로를 이름과 함께 저장하고, 탭 이동
    private func saveRoute(withName name: String) {
        let favoriteRoute = FavoriteRoute(name: name, favorites: places)
        delegate?.routeListViewController(self, didSaveFavoriteRoute: favoriteRoute)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.navigationItem.title = "경로 설정"
        }
        self.tabBarController?.selectedIndex = 2 // 즐겨찾기 탭으로 이동
    }
    
    
    // MARK: - UI Setup
    
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


// MARK: - Notification 이름 확장
extension Notification.Name {
    static let routeListDidUpdate = Notification.Name("routeListDidUpdate")
}


// MARK: - UITableView DataSource & Delegate

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
    
    /// 셀 이동 가능 설정
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /// 셀 이동 처리 (RouteListManager 순서 갱신)
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var current = RouteListManager.shared.selectedPlaces
        let movedPlace = current.remove(at: sourceIndexPath.row)
        current.insert(movedPlace, at: destinationIndexPath.row)
        RouteListManager.shared.setPlaces(current)
        tableView.reloadData()
    }
    
    /// 편집 모드에서 셀 삭제 스와이프 처리
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
