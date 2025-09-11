import UIKit
import CoreLocation
import NMapsMap

class ViewController: UIViewController, CLLocationManagerDelegate {
  private let locationManager = CLLocationManager()
  private let naverMapView = NMFNaverMapView(frame: .zero)
  private var currentCoordinate: NMGLatLng?
  
  // MARK: - 수정 1
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 지도 추가
    naverMapView.frame = view.bounds
    naverMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(naverMapView)
    
    // 내 위치 버튼
    naverMapView.showLocationButton = true
    naverMapView.mapView.locationOverlay.hidden = false
    
    // 위치 권한 및 시작
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    
    // MARK: - 수정 2
    setupAddButton()
  }
  
  // MARK: - 수정 3
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
  
  // MARK: - 수정 4
  @objc private func addButtonTapped() {
    print("플러스 버튼이 눌렸습니다.")
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let last = locations.last else { return }
    let coord = NMGLatLng(lat: last.coordinate.latitude, lng: last.coordinate.longitude)
    currentCoordinate = coord
    
    naverMapView.mapView.locationOverlay.location = coord
  }
}
