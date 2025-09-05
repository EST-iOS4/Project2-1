//
//  MusicItemCell.swift
//  Project2-1
//
//  Created by 남병수 on 9/5/25.
//

import UIKit

class MusicItemCell: UICollectionViewCell {
    
    // 썸네일 이미지뷰
    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .secondarySystemBackground // 이미지 로딩 전 배경색
        return imageView
    }()
    
    // 영상 제목 레이블
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 2 // 제목이 길면 두 줄까지
        return label
    }()
    
    // 채널 이름 레이블
    let channelTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(channelTitleLabel)
        
        // AutoLayout 설정
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        channelTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 130), // 썸네일 높이
            
            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            channelTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            channelTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            channelTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    // VideoItem 데이터로 UI를 설정하는 함수
    public func configure(with item: VideoItem) {
        titleLabel.text = item.snippet.title
        channelTitleLabel.text = item.snippet.channelTitle
        
        // 썸네일 URL로부터 이미지 로드 (아래 이미지 로더 코드가 필요합니다)
        if let url = URL(string: item.snippet.thumbnails.high.url) {
            thumbnailImageView.loadImage(from: url)
        }
    }
}


// 썸네일 이미지를 비동기적으로 로드하기 위한 도우미 코드입니다.
// 별도의 파일(예: UIImageView+Extension.swift)로 만들어도 좋고,
// MusicItemCell.swift 파일 맨 아래에 추가해도 됩니다.
extension UIImageView {
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }.resume()
    }
}
