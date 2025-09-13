import Foundation

struct FavoriteRoute: Codable {
    let name: String
    let favorites: [PlaceModel]
}
