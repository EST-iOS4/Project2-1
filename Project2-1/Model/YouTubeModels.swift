//
//  YouTubeModels.swift
//  Project2-1
//
//  Created by 남병수 on 9/5/25.
//

import Foundation

// API 응답 전체를 감싸는 구조체
struct YouTubeResponse: Codable {
    let items: [VideoItem]
}

// 개별 비디오 아이템
struct VideoItem: Codable {
    let snippet: Snippet
}

// 제목, 설명, 썸네일 등 주요 정보를 담는 스니펫
struct Snippet: Codable {
    let title: String
    let channelTitle: String
    let thumbnails: Thumbnails
}

// 썸네일 이미지 URL
struct Thumbnails: Codable {
    let high: Thumbnail
}

struct Thumbnail: Codable {
    let url: String
}
