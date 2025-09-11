import UIKit
import CoreLocation
import NMapsMap

class ViewController: UIViewController, CLLocationManagerDelegate {
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    naverMapView.frame = view.bounds
    naverMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(naverMapView)
    
    naverMapView.showLocationButton = true
    naverMapView.mapView.locationOverlay.hidden = false
    
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    
    setupAddButton()
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
  
  @objc private func addButtonTapped() {
    print("플러스 버튼이 눌렸습니다.")
    
    let routeListVC = RouteListViewController()
    let navigationController = UINavigationController(rootViewController: routeListVC)
    
    present(navigationController, animated: true, completion: nil)
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let last = locations.last else { return }
    let coord = NMGLatLng(lat: last.coordinate.latitude, lng: last.coordinate.longitude)
    currentCoordinate = coord
    
    naverMapView.mapView.locationOverlay.location = coord
  }
}
