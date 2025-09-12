import UIKit
import CoreLocation
import NMapsMap

class ViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    
    private let locationManager = CLLocationManager()
    private let naverMapView = NMFNaverMapView(frame: .zero)
    private var currentCoordinate: NMGLatLng?
    
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


    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMap()
        setupLocation()
        setupSearchButton()
    }

    // MARK: - 지도 설정
    private func setupMap() {
        naverMapView.frame = view.bounds
        naverMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(naverMapView)

        naverMapView.showLocationButton = true
        naverMapView.mapView.locationOverlay.hidden = false
    }

    // MARK: - 위치 권한
    private func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // MARK: - 검색창 설정
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

    // MARK: - 검색창 클릭 시 검색 화면으로 이동
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let searchVC = SearchView()
        navigationController?.pushViewController(searchVC, animated: true)
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }
        let coord = NMGLatLng(lat: last.coordinate.latitude, lng: last.coordinate.longitude)
        currentCoordinate = coord
        naverMapView.mapView.locationOverlay.location = coord
    }
    
    @objc func didTapSearch() {
        let serchVC = SearchView()
        navigationController?.pushViewController(serchVC, animated: true)
    }
}
