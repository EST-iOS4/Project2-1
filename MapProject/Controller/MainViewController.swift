import UIKit
import CoreLocation
import NMapsMap

class MainViewController: UIViewController {
    
    private var searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(" 🔍 장소를 검색하세요", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    
    private let locationManager = CLLocationManager() // iOS 내장 서비스 객체
    private let naverMapView = NMFNaverMapView(frame: .zero) // 네이버 지도 SDK에서 제공하는 지도 객체
    private var currentCoordinate: NMGLatLng?
    
    private var markers: [NMFMarker] = []
    private var routeLine: NMFPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MapView()
        SearchButton()
        searchButton.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)

        checkUserLocate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSelectedRoute()
    }
   
    private func MapView() { // 화면에 표시되는 지도
        naverMapView.frame = view.bounds
        naverMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        naverMapView.showLocationButton = true
        naverMapView.mapView.locationOverlay.hidden = false
        view.addSubview(naverMapView)
    }
    
    private func SearchButton() { // 상단의 검색 버튼
        view.addSubview(searchButton)
        
        NSLayoutConstraint.activate([
            searchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func checkUserLocate() { //처음 시작 시 위치 권환 요청 및 사용자 위치 지속적 업데이트
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}


extension MainViewController: CLLocationManagerDelegate { // 사용자의 위치 업데이트
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        currentCoordinate = coordinate
        naverMapView.mapView.locationOverlay.location = coordinate
    }
}



extension MainViewController {
    @objc private func didTapSearch() {
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }
}


extension MainViewController {
    private func updateSelectedRoute() {
        markers.forEach { $0.mapView = nil }
        markers.removeAll()
        
        routeLine?.mapView = nil
        routeLine = nil
        
        let coordinates: [NMGLatLng] = RouteListManager.shared.selectedPlaces.compactMap {
            guard let mapx = Double($0.mapx),
                  let mapy = Double($0.mapy) else {
                return nil
            }
            let lat = mapy / 10_000_000.0
            let lng = mapx / 10_000_000.0
            return NMGLatLng(lat: lat, lng: lng)
        }
        
        guard !coordinates.isEmpty else { return }
        
        for (index, coord) in coordinates.enumerated() {
            let marker = NMFMarker(position: coord)
            marker.captionText = "\(index + 1)"
            marker.mapView = naverMapView.mapView
            markers.append(marker)
        }
        
        let line = NMGLineString(points: coordinates as [AnyObject])
        let path = NMFPath()
        path.path = line
        path.color = .systemBlue
        path.width = 6
        path.mapView = naverMapView.mapView
        self.routeLine = path
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: coordinates[0])
        cameraUpdate.animation = .easeIn
        naverMapView.mapView.moveCamera(cameraUpdate)
    }
}
