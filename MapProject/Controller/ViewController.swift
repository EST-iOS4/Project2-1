import UIKit
import CoreLocation
import NMapsMap

class ViewController: UIViewController, CLLocationManagerDelegate, UISearchResultsUpdating {
  private let locationManager = CLLocationManager()
  private let naverMapView = NMFNaverMapView(frame: .zero)
  private var currentCoordinate: NMGLatLng?
  
  private let addButton: UIButton = {
    let button = UIButton()
    let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
    button.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
    
    button.backgroundColor = .white
    button.tintColor = .darkGray
    button.layer.cornerRadius = 25
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOpacity = 0.3
    button.layer.shadowOffset = CGSize(width: 0, height: 2)
    button.layer.shadowRadius = 4
    
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  // 검색 컨트롤러
  let searchController = UISearchController(searchResultsController: nil)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 네이버 지도 세팅
    naverMapView.frame = view.bounds
    naverMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(naverMapView)
    
    naverMapView.showLocationButton = true
    naverMapView.mapView.locationOverlay.hidden = false
    
    // 위치 권한 요청
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    
    // UI 세팅
    setupAddButton()
    setupSearchBar() // 검색 기능 추가
  }
  
  private func setupAddButton() {
    view.addSubview(addButton)
    
    addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    
    NSLayoutConstraint.activate([
      addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
      addButton.widthAnchor.constraint(equalToConstant: 50),
      addButton.heightAnchor.constraint(equalToConstant: 50)
    ])
  }
  
  private func setupSearchBar() {
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "장소를 검색하세요"
    
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    definesPresentationContext = true
  }
  
  @objc private func addButtonTapped() {
    print("플러스 버튼이 눌렸습니다.")
    self.tabBarController?.selectedIndex = 1
  }
  
  // 위치 업데이트
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let last = locations.last else { return }
    let coord = NMGLatLng(lat: last.coordinate.latitude, lng: last.coordinate.longitude)
    currentCoordinate = coord
    
    naverMapView.mapView.locationOverlay.location = coord
  }
  
  // 검색 이벤트 처리
  func updateSearchResults(for searchController: UISearchController) {
    guard let keyword = searchController.searchBar.text, !keyword.isEmpty else { return }
    print("검색어: \(keyword)")
    // 여기서 Naver Local API 호출 → 검색 결과 처리 가능
  }
}
