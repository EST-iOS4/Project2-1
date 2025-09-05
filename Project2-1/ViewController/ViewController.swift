import UIKit
import SnapKit
import SwiftyDropbox
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("드롭박스 로그인", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    private let loadVideosButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("영상 목록 불러오기", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.isEnabled = false
        return button
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "드롭박스에 로그인해주세요"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.layer.cornerRadius = 10
        table.layer.borderWidth = 1
        table.layer.borderColor = UIColor.systemGray4.cgColor
        return table
    }()
    
    // 데이터
    private var videoFiles: [Files.FileMetadata] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupActions()
        checkAuthStatus()
        
        // 드롭박스 인증 성공 알림 등록
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dropboxAuthSuccess),
            name: NSNotification.Name("DropboxAuthSuccess"),
            object: nil
        )
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(loginButton)
        view.addSubview(loadVideosButton)
        view.addSubview(statusLabel)
        view.addSubview(tableView)
        
        loginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        loadVideosButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(loginButton.snp.bottom).offset(20)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(loadVideosButton.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "VideoCell")
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        loadVideosButton.addTarget(self, action: #selector(loadVideosButtonTapped), for: .touchUpInside)
    }
    
    private func checkAuthStatus() {
        if DropboxClientsManager.authorizedClient != nil {
            // 이미 인증된 상태
            updateUIForLoggedIn()
        }
    }
    
    @objc private func loginButtonTapped() {
        guard let topController = UIApplication.shared.windows.first?.rootViewController else { return }
        
        
        let scopeRequest = ScopeRequest(
             scopeType: .user,
             scopes: ["files.metadata.read", "files.content.read"], // 필요 스코프
             includeGrantedScopes: true
         )
        DropboxClientsManager.authorizeFromControllerV2(
            UIApplication.shared,
            controller: topController,
            loadingStatusDelegate: nil,
            openURL: { (url: URL) -> Void in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            },
            scopeRequest: scopeRequest
        )
    }
    
    @objc private func loadVideosButtonTapped() {
        loadVideoList()
    }
    
    @objc private func dropboxAuthSuccess() {
        DispatchQueue.main.async {
            self.updateUIForLoggedIn()
        }
    }
    
    private func updateUIForLoggedIn() {
        loginButton.setTitle("드롭박스 로그인 완료", for: .normal)
        loginButton.backgroundColor = .systemGray
        loginButton.isEnabled = false
        
        loadVideosButton.isEnabled = true
        statusLabel.text = "로그인 완료! 영상 목록을 불러와보세요."
    }
    
    private func loadVideoList() {
        guard let client = DropboxClientsManager.authorizedClient else {
            statusLabel.text = "드롭박스 인증이 필요합니다"
            return
        }

        statusLabel.text = "영상 목록 불러오는 중..."
        loadVideosButton.isEnabled = false
        tableView.isHidden = true
        
        // 특정 공유 폴더의 영상 파일들 가져오기
        client.files.listFolder(path: "")
            .response { response, error in
                DispatchQueue.main.async {
                    self.loadVideosButton.isEnabled = true
                    
                    if let error = error {
                        self.statusLabel.text = "목록 불러오기 실패: \(error.localizedDescription)"
                        print("목록 불러오기 오류: \(error)")
                        return
                    }
                    
                    if let result = response {
                        // 영상 파일만 필터링 (mp4, mov, avi, mkv 등)
                        let videoExtensions = ["mp4", "mov", "avi", "mkv", "m4v", "wmv", "flv"]
                        let names = result.entries.map(\.name)
                        print("경로내 파일들:", names)
                        
                        self.videoFiles = result.entries.compactMap { entry in
                            if let file = entry as? Files.FileMetadata {
                                let fileName = file.name.lowercased()
                                let hasVideoExtension = videoExtensions.contains { ext in
                                    fileName.hasSuffix(".\(ext)")
                                }
                                return hasVideoExtension ? file : nil
                            }
                            return nil
                        }
                        
                        if self.videoFiles.isEmpty {
                            self.statusLabel.text = "폴더에 영상 파일이 없습니다."
                        } else {
                            self.statusLabel.text = "\(self.videoFiles.count)개의 영상을 찾았습니다. 재생할 영상을 선택하세요."
                            self.tableView.isHidden = false
                            self.tableView.reloadData()
                        }
                    }
                
                }
            }
    }
    
    private func downloadAndPlayVideo(file: Files.FileMetadata) {
        guard let client = DropboxClientsManager.authorizedClient else { return }
        
        statusLabel.text = "\(file.name) 다운로드 중..."
        
        // 임시 파일 경로 생성
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let localFilePath = (documentsPath as NSString).appendingPathComponent(file.name)
        let localURL = URL(fileURLWithPath: localFilePath)
        
        // 드롭박스에서 파일 다운로드
        client.files.download(path: file.pathLower!, overwrite: true, destination: localURL)
            .response { response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.statusLabel.text = "다운로드 실패: \(error.localizedDescription)"
                        print("다운로드 오류: \(error)")
                        return
                    }
                    
                    if response != nil {
                        self.statusLabel.text = "다운로드 완료! \(file.name) 재생 중..."
                        self.playVideo(at: localURL)
                    }
                }
            }
    }
    
    private func playVideo(at url: URL) {
        let player = AVPlayer(url: url)
        let playerController = AVPlayerViewController()
        playerController.player = player
        
        present(playerController, animated: true) {
            player.play()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - TableView DataSource & Delegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath)
        let file = videoFiles[indexPath.row]
        
        cell.textLabel?.text = file.name
        cell.detailTextLabel?.text = formatFileSize(file.size)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedFile = videoFiles[indexPath.row]
        downloadAndPlayVideo(file: selectedFile)
    }
    
    private func formatFileSize(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

