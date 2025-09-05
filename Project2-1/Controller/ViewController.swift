//
//  ViewController.swift
//  Project2-1
//
//  Created by 남병수 on 9/5/25.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView()
    
    // API로부터 받아온 데이터를 담을 배열
    var musicItems: [VideoItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        self.title = "Music Home"
        
        setupTableView()
        fetchData() // ⭐️ viewDidLoad에서 데이터 요청 시작
    }
    
    // ⭐️ API 데이터를 가져오는 함수
    private func fetchData() {
        YouTubeAPIManager.shared.fetchTrendingMusic { [weak self] result in
            switch result {
            case .success(let items):
                self?.musicItems = items
                
                // ⭐️ 중요: 네트워크 작업은 백그라운드에서 처리되므로,
                // UI 업데이트는 반드시 메인 스레드에서 해야 합니다.
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print("데이터를 가져오는 데 실패했습니다: \(error)")
            }
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MusicRowCell.self, forCellReuseIdentifier: "MusicRowCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // ⭐️ 이제 musicItems 배열의 개수만큼 행을 표시합니다.
        // 여기서는 하나의 행에 모든 아이템을 가로로 표시할 것이므로 1을 반환합니다.
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicRowCell", for: indexPath) as! MusicRowCell
        // ⭐️ 셀에 전체 비디오 목록을 전달합니다.
        cell.configure(with: musicItems)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
}
