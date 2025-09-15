import UIKit
import CoreLocation
import NMapsMap

class ViewController: UIViewController, CLLocationManagerDelegate {
  
  private let searchButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle(" 🔍 장소를 검색하세요", for: .normal)
    button.setTitleColor(.gray, for: .normal)
    button.contentHorizontalAlignment = .left
    button.backgroundColor = UIColor.systemGray6
    button.layer.cornerRadius = 10
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  private let locationManager = CLLocationManager()
  private let naverMapView = NMFNaverMapView(frame: .zero)
  private var currentCoordinate: NMGLatLng?
  
  private var markers: [NMFMarker] = []
  private var routeLine: NMFPath?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupMap()
    setupLocation()
    setupSearchButton()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    drawPolylineRoute()
  }
  
  private func setupSearchButton() {
    view.addSubview(searchButton)
    
    NSLayoutConstraint.activate([
      searchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
      searchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      searchButton.heightAnchor.constraint(equalToConstant: 44)
    ])
    
    searchButton.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)
  }
  
  @objc private func didTapSearch() {
    let searchVC = SearchViewController()
    navigationController?.pushViewController(searchVC, animated: true)
  }
  
  private func setupMap() {
    naverMapView.frame = view.bounds
    naverMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(naverMapView)
    naverMapView.showLocationButton = true
    naverMapView.mapView.locationOverlay.hidden = false
  }
  
  private func setupLocation() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    
    DispatchQueue.global().async {
      if CLLocationManager.locationServicesEnabled() {
        print("📍 위치 서비스 켜짐")
        self.locationManager.startUpdatingLocation()
      } else {
        print("❌ 위치 서비스 꺼짐")
      }
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let last = locations.last else { return }
    let coord = NMGLatLng(lat: last.coordinate.latitude, lng: last.coordinate.longitude)
    currentCoordinate = coord
    naverMapView.mapView.locationOverlay.location = coord
  }
  
  private func drawPolylineRoute() {
    markers.forEach { $0.mapView = nil }
    markers.removeAll()
    routeLine?.mapView = nil
    routeLine = nil
    
    let placeCoords: [NMGLatLng] = RouteListManager.shared.selectedPlaces.compactMap {
      guard let mapx = Double($0.mapx), let mapy = Double($0.mapy) else {
        return nil
      }
      let tmCoord = NMGTm128(x: mapx, y: mapy)
      return tmCoord.toLatLng()
    }
    
    guard placeCoords.count >= 2 else { return }
    
    NaverLocalAPI.shared.findDirections(coordinates: placeCoords) { [weak self] routeCoords in
      guard let self = self, let routeCoords = routeCoords, !routeCoords.isEmpty else {
        print("❌ 경로 탐색 결과가 없거나 실패했습니다.")
        return
      }
      
      DispatchQueue.main.async {
        let lineString = NMGLineString(points: routeCoords as [AnyObject])
        let newRouteLine = NMFPath()
        newRouteLine.path = lineString
        newRouteLine.color = UIColor.systemBlue
        newRouteLine.width = 6
        newRouteLine.mapView = self.naverMapView.mapView
        self.routeLine = newRouteLine
        
        for (index, coord) in placeCoords.enumerated() {
          let marker = NMFMarker(position: coord)
          marker.captionText = "\(index + 1)"
          marker.mapView = self.naverMapView.mapView
          self.markers.append(marker)
        }
        
        let bounds = NMGLatLngBounds(latLngs: placeCoords)
        
        let cameraUpdate = NMFCameraUpdate(fit: bounds, padding: 50)
        cameraUpdate.animation = .easeIn
        self.naverMapView.mapView.moveCamera(cameraUpdate)
      }
    }
  }
}
