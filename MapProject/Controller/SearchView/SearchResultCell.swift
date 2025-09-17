import UIKit

class SearchResultCell: UITableViewCell {
    static let identifier = "SearchResultCell"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0 // 여러 줄 지원
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0 // 여러 줄 지원
        return label
    }()
    
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("추가", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.tintColor = .systemBlue
        return button
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    func configure(with place: PlaceModel, isAdded: Bool) {
        titleLabel.text = place.title.removingHTMLTags()
        addressLabel.text = place.roadAddress.isEmpty ? place.address : place.roadAddress
        updateButton(isAdded: isAdded, animated: false)
    }
    
    func updateButton(isAdded: Bool, animated: Bool) {
        let duration = animated ? 0.25 : 0.0
        UIView.animate(withDuration: duration) {
            if isAdded {
                self.addButton.setTitle(nil, for: .normal)
                self.addButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
                self.addButton.tintColor = .systemGreen
                self.addButton.isEnabled = false
            } else {
                self.addButton.setTitle("추가", for: .normal)
                self.addButton.setImage(nil, for: .normal)
                self.addButton.tintColor = .systemBlue
                self.addButton.isEnabled = true
            }
        }
    }
    
    // MARK: - Layout
    
    private func setupViews() {
        let textStackView = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        textStackView.axis = .vertical
        textStackView.spacing = 4
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [textStackView, addButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // 텍스트 영역
            textStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            textStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            textStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textStackView.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -12),
            
            // 추가 버튼
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
}

extension String {
    func removingHTMLTags() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
