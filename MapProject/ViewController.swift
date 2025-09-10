import UIKit
import CoreLocation
import NMapsMap

class ViewController: UIViewController, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let naverMapView = NMFNaverMapView(frame: .zero)
    private var currentCoordinate: NMGLatLng?

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
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }
        let coord = NMGLatLng(lat: last.coordinate.latitude, lng: last.coordinate.longitude)
        currentCoordinate = coord

        naverMapView.mapView.locationOverlay.location = coord
    }
}
