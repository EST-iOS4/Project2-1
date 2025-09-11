import UIKit

class RouteListViewController: UIViewController {
  
  // MARK: - Properties
  
  var places: [Place] = [
    Place(name: "강남역", address: "서울 강남구 강남대로"),
    Place(name: "코엑스", address: "서울 강남구 영동대로 513"),
    Place(name: "롯데월드타워", address: "서울 송파구 올림픽로 300")
  ]
  
  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "placeCell")
    return tableView
  }()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    setupTableView()
    
    let favoritesButton = UIBarButtonItem(image: UIImage(systemName: "star"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(favoritesButtonTapped))
    
    navigationItem.leftBarButtonItem = favoritesButton
    navigationItem.rightBarButtonItem = editButtonItem
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
      super.setEditing(editing, animated: animated)
      
      tableView.setEditing(editing, animated: animated)
  }
  
  // MARK: - Actions

  @objc private func favoritesButtonTapped() {
    let alertController = UIAlertController(title: "경로 저장",
                                            message: "이 경로의 이름을 입력하세요.",
                                            preferredStyle: .alert)
    alertController.addTextField { textField in
      textField.placeholder = "예: 우리집에서 회사까지"
      print("즐겨찾기 버튼이 눌렸습니다.")
    }
    
    let saveAction = UIAlertAction(title: "저장", style: .default) { [weak self] _ in
      guard let routeName = alertController.textFields?.first?.text, !routeName.isEmpty else {
        print("경로 이름이 입력되지 않았습니다.")
        return
      }
      self?.saveRoute(withName: routeName)
    }
    
    let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    
    alertController.addAction(saveAction)
    alertController.addAction(cancelAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
  // MARK: - Helper Methods

  // 저장 로직을 처리하는 별도의 함수 (지금은 콘솔 출력)
  private func saveRoute(withName name: String) {
      print("--- 즐겨찾기 저장 ---")
      print("경로 이름: \(name)")
      
      // self.places 배열에 있는 현재 경로 목록을 출력
      let placeNames = self.places.map { $0.name }.joined(separator: " -> ")
      print("경로 목록: \(placeNames)")
      print("--------------------")
      
      // TODO: 여기에 실제 데이터를 UserDefaults나 CoreData 등에 저장하는 코드를 추가합니다.
      
      // TODO: 저장이 완료되면 즐겨찾기 화면으로 이동하는 코드를 추가합니다.
      // self.tabBarController?.selectedIndex = 2 // 즐겨찾기 탭(세 번째)으로 이동
  }

  // MARK: - Setup
  
  private func setupUI() {
    view.backgroundColor = .systemBackground
    title = "경로 설정"
    
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

extension RouteListViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return places.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)
    let place = places[indexPath.row]
    
    var content = cell.defaultContentConfiguration()
    content.text = place.name
    content.secondaryText = place.address
    cell.contentConfiguration = content
    
    return cell
    
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      places.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
  
  func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let movedPlace = places.remove(at: sourceIndexPath.row)
    places.insert(movedPlace, at: destinationIndexPath.row)
  }
}
