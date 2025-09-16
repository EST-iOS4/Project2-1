import Foundation

class RouteListManager {
    static let shared = RouteListManager()
    private(set) var selectedPlaces: [PlaceModel] = []

    func add(_ place: PlaceModel) {
        selectedPlaces.append(place)
        NotificationCenter.default.post(name: .routeListDidUpdate, object: nil)
    }

    func remove(_ place: PlaceModel) {
        selectedPlaces.removeAll { $0 == place }
        NotificationCenter.default.post(name: .routeListDidUpdate, object: nil)
    }

    func setPlaces(_ places: [PlaceModel]) {
        selectedPlaces = places
        NotificationCenter.default.post(name: .routeListDidUpdate, object: nil)
    }

    func clear() {
        selectedPlaces.removeAll()
        NotificationCenter.default.post(name: .routeListDidUpdate, object: nil)
    }
}
