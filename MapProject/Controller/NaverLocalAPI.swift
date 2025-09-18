import Foundation

class NaverLocalAPI {
    static let shared = NaverLocalAPI()
    
    private init() {}

    private var clientID: String {
        Bundle.main.object(forInfoDictionaryKey: "NaverClientID") as? String ?? ""
    }

    private var clientSecret: String {
        Bundle.main.object(forInfoDictionaryKey: "NaverClientSecret") as? String ?? ""
    }

    /// 네이버 로컬 검색
    /// - Parameters:
    ///   - keyword: 검색어
    ///   - start: 검색 시작 위치 (1 ~ 1000, 기본값 1)
    ///   - display: 한 번에 불러올 개수 (1 ~ 30, 기본값 30)
    ///   - completion: 결과 콜백
    func search(keyword: String,
                start: Int = 1,
                display: Int = 30,
                completion: @escaping ([PlaceModel]) -> Void) {
        
        guard let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://openapi.naver.com/v1/search/local.json?query=\(encoded)&display=\(display)&start=\(start)&sort=random") else {
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

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 응답 코드:", httpResponse.statusCode)
            }

            // 👉 JSON 원문 출력 (디버깅용)
            if let raw = String(data: data, encoding: .utf8) {
                print("📥 응답 JSON:\n\(raw)")
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
}

struct NaverSearchResponse: Decodable {
    let items: [PlaceModel]
}
