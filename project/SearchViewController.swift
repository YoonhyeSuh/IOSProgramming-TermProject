//
//  SearchViewController.swift
//  project
//
//  Created by yhSuh on 2024/06/16.
//

import UIKit
import Foundation

// SearchViewController 클래스는 음식 데이터를 검색하고 테이블 뷰에 표시하는 역할을 합니다.
class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // 테이블 뷰와 서치 바 아울렛
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // 모든 음식 데이터와 필터링된 음식 데이터를 저장하는 배열
    var foodItems: [Food] = []
    var filteredFoodItems: [Food] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "음식 검색"
        
        // 서치바 설정
        searchBar.delegate = self
        searchBar.placeholder = "음식 이름을 입력하세요"
        
        // 테이블뷰 설정
        tableView.dataSource = self
        tableView.delegate = self
        
        // JSON 파일에서 음식 데이터를 로드하여 배열에 저장
        if let items = loadJSON() {
            foodItems = items
            filteredFoodItems = items
            tableView.reloadData() // 데이터 로드 후 테이블 뷰 리로드
        }
    }
    
    // JSON 파일을 로드하여 Food 객체 배열을 반환하는 함수
    func loadJSON() -> [Food]? {
        if let url = Bundle.main.url(forResource: "Food", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let foodItems = try decoder.decode([Food].self, from: data)
                return foodItems
            } catch {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    // UITableViewDataSource 메서드: 섹션 당 행의 수를 반환
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFoodItems.count
    }
    
    // UITableViewDataSource 메서드: 각 행에 대한 셀을 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = filteredFoodItems[indexPath.row]
        cell.textLabel?.text = "\(item.name) - \(item.calories) kcal"
        return cell
    }
    
    // UISearchBarDelegate 메서드: 검색 텍스트가 변경될 때 호출
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredFoodItems = foodItems
        } else {
            filteredFoodItems = foodItems.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }
    
    // UISearchBarDelegate 메서드: 검색 취소 버튼이 클릭될 때 호출
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredFoodItems = foodItems
        tableView.reloadData()
    }
}
