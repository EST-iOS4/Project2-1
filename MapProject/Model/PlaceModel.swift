import Foundation

struct PlaceModel: Codable, Equatable {
    let title: String
    let category: String
    let address: String
    let roadAddress: String
    let mapx: String
    let mapy: String
  
  static func == (lhs: PlaceModel, rhs: PlaceModel) -> Bool {
    return lhs.address == rhs.address
  }
}
