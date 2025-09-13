import UIKit

class SearchView: UIViewController, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var searchResults: [PlaceModel] = []
    private var searchHistory: [String] = []
    private var showingHistory = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupSearchController()
        setupTableView()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "장소를 검색하세요"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.identifier)
        
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - 검색어 입력 시 호출
    func updateSearchResults(for searchController: UISearchController) {
        guard let keyword = searchController.searchBar.text, !keyword.isEmpty else {
            showingHistory = true
            tableView.reloadData()
            return
        }
        
        
        showingHistory = false
        
        NaverLocalAPI.shared.search(keyword: keyword) { results in
            DispatchQueue.main.async {
                self.searchResults = results
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - 검색창 클릭 시 기록 보여주기
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        showingHistory = true
        tableView.reloadData()
    }
    
    // MARK: - 취소 시 기록 숨기기
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        showingHistory = false
        tableView.reloadData()
    }
    
    // MARK: - 테이블뷰 데이터
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showingHistory ? searchHistory.count : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showingHistory {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            let keyword = searchHistory[indexPath.row]
            cell.textLabel?.text = keyword
            cell.detailTextLabel?.text = "이전 검색어"
            cell.detailTextLabel?.textColor = .gray
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.identifier, for: indexPath) as? SearchResultCell else {
                return UITableViewCell()
            }
            
            let place = searchResults[indexPath.row]
            cell.titleLabel.text = place.title.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
            cell.detailLabel.text = place.roadAddress.isEmpty ? place.address : place.roadAddress
            
            // 버튼 액션 정의
            cell.actionButton.setTitle("추가", for: .normal) // 또는 상황에 따라 "삭제"
            cell.onButtonTap = { [weak self] in
                guard let self = self else { return }
                print("➕ 버튼 눌림: \(place.title)")
                // TODO: 추가 또는 삭제 동작 수행
            }
            
            return cell
        }
    }
    
    
    // MARK: - 셀 클릭
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showingHistory {
            let keyword = searchHistory[indexPath.row]
            searchController.searchBar.text = keyword
            searchController.searchBar.resignFirstResponder()
            updateSearchResults(for: searchController)
        } else {
            let place = searchResults[indexPath.row]
            let keyword = searchController.searchBar.text ?? ""
            
            // ✅ 이 시점에만 검색 기록에 추가
            if !searchHistory.contains(keyword) {
                searchHistory.insert(keyword, at: 0)
                if searchHistory.count > 10 {
                    searchHistory.removeLast()
                }
            }
            
            print("📍 선택된 장소: \(place.title) / \(place.mapx), \(place.mapy)")
            // TODO: RouteListViewController로 넘기기 가능
        }
    }
    
    
}
