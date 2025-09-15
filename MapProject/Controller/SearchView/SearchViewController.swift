import UIKit

class SearchViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    // MARK: - Properties
    
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var searchResults: [PlaceModel] = []
    private var searchHistory: [String] = []
    private var showingHistory = true
    
    // MARK: - Lifecycle
    
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    
    setupSearchController()
    setupTableView()
  }
    
    // MARK: - Setup
    
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
    
    // MARK: - UISearchResultsUpdating
    
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
    
    // MARK: - UISearchBarDelegate
    
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    showingHistory = true
    tableView.reloadData()
  }
    
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    showingHistory = false
    tableView.reloadData()
  }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < searchResults.count else { return }
        
        let placeToAdd = searchResults[index]
        
        RouteListManager.shared.add(placeToAdd)
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.impactOccurred()
        
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SearchResultCell {
            cell.updateButton(isAdded: true, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return showingHistory ? searchHistory.count : searchResults.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.identifier, for: indexPath) as? SearchResultCell else {
      return UITableViewCell()
    }
    
    let place = searchResults[indexPath.row]
    
    let isAlreadyAdded = RouteListManager.shared.selectedPlaces.contains(where: { $0.address == place.address })
    
    cell.configure(with: place, isAdded: isAlreadyAdded)
    
    cell.addButton.tag = indexPath.row
    cell.addButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if showingHistory {
      let keyword = searchHistory[indexPath.row]
      searchController.searchBar.text = keyword
      searchController.searchBar.resignFirstResponder()
      updateSearchResults(for: searchController)
    } else {
      let place = searchResults[indexPath.row]
      let keyword = searchController.searchBar.text ?? ""
      
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
