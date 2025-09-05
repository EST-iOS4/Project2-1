//
//  YouTubeAPIManager.swift
//  Project2-1
//
//  Created by 남병수 on 9/5/25.
//

import Foundation

class YouTubeAPIManager {
    
    // 싱글톤으로 만들어 어디서든 쉽게 접근할 수 있게 합니다.
    static let shared = YouTubeAPIManager()
    
    private let apiKey = "AIzaSyA1oaUgwgOefzWg6G3PzhQ6fgRqqCIftjs"
    private let baseURL = "https://www.googleapis.com/youtube/v3/videos"
    
    private init() {} // 외부에서 인스턴스를 또 생성하는 것을 방지
    
    // "지금 뜨는 인기 음악"을 가져오는 함수
    func fetchTrendingMusic(completion: @escaping (Result<[VideoItem], Error>) -> Void) {
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "chart", value: "mostPopular"),
            URLQueryItem(name: "videoCategoryId", value: "10"), // "10"은 음악 카테고리입니다.
            URLQueryItem(name: "maxResults", value: "20"), // 20개만 가져오기
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = components.url else {
            print("Error: cannot create URL")
            return
        }
        
        // URLSession을 사용해 데이터를 요청합니다.
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("Error: Did not receive data")
                return
            }
            
            // JSON 데이터를 우리가 만든 모델로 변환(디코딩)합니다.
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(YouTubeResponse.self, from: data)
                completion(.success(response.items))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
