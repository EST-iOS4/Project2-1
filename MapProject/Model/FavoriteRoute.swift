import Foundation

struct FavoriteRoute: Codable, Equatable {
    var name: String
    let favorites: [PlaceModel]
  
  static func == (lhs: FavoriteRoute, rhs: FavoriteRoute) -> Bool {
    return lhs.name == rhs.name && lhs.favorites == rhs.favorites
  }
}
