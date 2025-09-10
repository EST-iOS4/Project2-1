import Foundation
import CoreLocation

struct NaverPlace: Codable {
    let title: String
    let category: String
    let address: String
    let roadAddress: String
    let mapx: String
    let mapy: String
}

struct NaverLocalSearchResponse: Codable {
    let items: [NaverPlace]
}

class NaverLocalApiManager {
    static let shared = NaverLocalApiManager()
    
    private let clientID = "H354eLVdGvBFL07bjSwr"
    private let clientPW = "cOYnGxcUmT"
    
    func searchPlaces(query: String, completion: @escaping ([NaverPlace]) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("invalid URL")
            return
        }
        
        let urlString = "https://openapi.naver.com/v1/search/local.json?query=\(encodedQuery)&display=5&sort=comment"

        guard let url = URL(string: urlString) else {
            print("❌ URL 생성 실패")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(clientID, forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue(clientPW, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ API Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                let result = try JSONDecoder().decode(NaverLocalSearchResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(result.items)
                }
            } catch {
                print("❌ JSON Parsing Error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
