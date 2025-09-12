import Foundation

struct Place {
    let name: String
    let address: String
}

struct PlaceModel: Decodable {
    let title: String
    let link: String
    let category: String
    let description: String
    let telephone: String
    let address: String
    let roadAddress: String
    let mapx: String
    let mapy: String
}
