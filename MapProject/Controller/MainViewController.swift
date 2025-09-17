import UIKit
import CoreLocation
import NMapsMap

class MainViewController: UIViewController {
    
    private let locationManager = CLLocationManager() // iOS 내장 서비스 객체
    private let naverMapView = NMFNaverMapView(frame: .zero) // 네이버 지도 SDK에서 제공하는 지도 객체
    private var currentCoordinate: NMGLatLng?
    
    private var markers: [NMFMarker] = []
    private var routeLine: NMFPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        checkUserLocate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSelectedRoute()
    }
   
    private func setupMapView() { // 화면에 표시되는 지도
        naverMapView.frame = view.bounds
        naverMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        naverMapView.showLocationButton = true
        naverMapView.mapView.locationOverlay.hidden = false
        view.addSubview(naverMapView)
    }
    
    private func checkUserLocate() { // 앱 실행 시 위치 권환 요청
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
    private func updateSelectedRoute() {
        // 기존 마커/경로 초기화
        markers.forEach { $0.mapView = nil }
        markers.removeAll()
        
        routeLine?.mapView = nil
        routeLine = nil
        
        // 선택된 장소 → 좌표 변환
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
        
        // 마커 생성
        for (index, coord) in coordinates.enumerated() {
            let marker = NMFMarker(position: coord)
            marker.captionText = "\(index + 1)"
            marker.mapView = naverMapView.mapView
            markers.append(marker)
        }
        
        // 경로 라인
        let line = NMGLineString(points: coordinates as [AnyObject])
        let path = NMFPath()
        path.path = line
        path.color = .systemBlue
        path.width = 6
        path.mapView = naverMapView.mapView
        self.routeLine = path
        
        // 카메라 이동
        let cameraUpdate = NMFCameraUpdate(scrollTo: coordinates[0])
        cameraUpdate.animation = .easeIn
        naverMapView.mapView.moveCamera(cameraUpdate)
    }
}
