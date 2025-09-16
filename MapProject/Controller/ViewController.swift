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
    
    private let locationManager = CLLocationManager() // iOS 내장 위치 서비스 객체
    
    private let naverMapView = NMFNaverMapView(frame: .zero) // 네이버 지도 SDK에서 제공하는 지도 객체
    
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
    
    private func setupSearchButton() { // 상단의 검색 버튼
        view.addSubview(searchButton)
        
        NSLayoutConstraint.activate([
            searchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        searchButton.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside) // didtapSearch() 호출
    }
    
    @objc private func didTapSearch() { // navigationController를 통한 검색 화면으로 화면 전환
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    private func setupMap() { // 화면에 표시되는 지도
        naverMapView.frame = view.bounds
        naverMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(naverMapView)
        naverMapView.showLocationButton = true
        naverMapView.mapView.locationOverlay.hidden = false
    }
    
    private func setupLocation() { // 처음 시작 시 위치 권한 요청, 지속적인 사용자의 위치 업데이트
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { // 사용자의 위치 업데이트
        guard let last = locations.last else { return }
        let coord = NMGLatLng(lat: last.coordinate.latitude, lng: last.coordinate.longitude)
        currentCoordinate = coord
        naverMapView.mapView.locationOverlay.location = coord
    }
    
    private func drawPolylineRoute() { // 경로 설정된 경로들을 마커로 표시 및 선으로 시각화
        markers.forEach { $0.mapView = nil }
        markers.removeAll()
        
        routeLine?.mapView = nil
        routeLine = nil
        
        let coords: [NMGLatLng] = RouteListManager.shared.selectedPlaces.compactMap { //경로 설정에서 선택된 장소 출발지, 목적지 호출
            guard let mapx = Double($0.mapx),
                  let mapy = Double($0.mapy)
            else {
                return nil
            }
            
            //위도, 경도 값 변환
            let lat = mapy / 10_000_000.0
            let lng = mapx / 10_000_000.0
            return NMGLatLng(lat: lat, lng: lng)
        }
        
        guard !coords.isEmpty else { return }
        
        for (index, coord) in coords.enumerated() {
            let marker = NMFMarker(position: coord)
            marker.captionText = "\(index + 1)"
            marker.mapView = naverMapView.mapView
            markers.append(marker)
        }
        
        let lineString = NMGLineString(points: coords as [AnyObject])
        
        let newRouteLine = NMFPath()
        newRouteLine.path = lineString
        newRouteLine.color = UIColor.systemBlue
        newRouteLine.width = 6
        newRouteLine.mapView = naverMapView.mapView
        self.routeLine = newRouteLine
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: coords[0])
        cameraUpdate.animation = .easeIn
        naverMapView.mapView.moveCamera(cameraUpdate)
    }
}
