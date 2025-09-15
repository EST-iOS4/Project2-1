import Foundation
import NMapsMap

class NaverLocalAPI {
  static let shared = NaverLocalAPI()
  
  private init() {}
  
  private var clientID: String {
    Bundle.main.object(forInfoDictionaryKey: "NaverClientID") as? String ?? ""
  }
  
  private var clientSecret: String {
    Bundle.main.object(forInfoDictionaryKey: "NaverClientSecret") as? String ?? ""
  }
  
  // MARK: - Local Search API
  
  func search(keyword: String, completion: @escaping ([PlaceModel]) -> Void) {
    guard let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: "https://openapi.naver.com/v1/search/local.json?query=\(encoded)&display=10&start=1&sort=random") else {
      completion([])
      return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue(clientID, forHTTPHeaderField: "X-Naver-Client-Id")
    request.addValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print("❌ 네트워크 오류:", error)
        completion([])
        return
      }
      
      guard let data = data else {
        print("❌ 데이터 없음")
        completion([])
        return
      }
      
      do {
        let json = try JSONDecoder().decode(NaverSearchResponse.self, from: data)
        completion(json.items)
      } catch {
        print("❌ JSON 파싱 오류:", error)
        completion([])
      }
    }.resume()
  }
  
  // MARK: - Directions API
  
  func findDirections(coordinates: [NMGLatLng], completion: @escaping ([NMGLatLng]?) -> Void) {
    guard coordinates.count >= 2 else {
      completion(nil)
      return
    }
    
    let start = "\(coordinates.first!.lng),\(coordinates.first!.lat)"
    let goal = "\(coordinates.last!.lng),\(coordinates.last!.lat)"
    
    var waypoints = ""
    if coordinates.count > 2 {
      waypoints = coordinates[1..<coordinates.count-1]
        .map { "\($0.lng),\($0.lat)" }
        .joined(separator: "|")
    }
    
    let urlString = "https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving?start=\(start)&goal=\(goal)&waypoints=\(waypoints)&option=trafast"
    
    guard let url = URL(string: urlString) else {
      completion(nil)
      return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(clientID, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
    request.setValue(clientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      guard let data = data, error == nil else {
        print("❌ Directions API 네트워크 오류: \(error?.localizedDescription ?? "알 수 없음")")
        completion(nil)
        return
      }
      
      do {
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let route = json["route"] as? [String: Any],
           let trafast = route["trafast"] as? [[String: Any]],
           let path = trafast.first?["path"] as? [[Double]] {
          
          let routeCoordinates = path.map { NMGLatLng(lat: $0[1], lng: $0[0]) }
          completion(routeCoordinates)
        } else {
          print("❌ Directions API 응답에서 경로를 찾을 수 없음")
          completion(nil)
        }
      } catch {
        print("❌ Directions API JSON 파싱 오류: \(error.localizedDescription)")
        completion(nil)
      }
    }.resume()
  }
}

struct NaverSearchResponse: Decodable {
  let items: [PlaceModel]
}
