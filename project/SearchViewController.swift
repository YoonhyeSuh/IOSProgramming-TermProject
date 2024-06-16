//
//  SearchViewController.swift
//  project
//
//  Created by yhSuh on 2024/06/16.
//

import UIKit
import Foundation

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
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
        
        if let items = loadJSON() {
            foodItems = items
            filteredFoodItems = items
            tableView.reloadData() // 데이터 로드 후 테이블 뷰 리로드
        }
    }
    
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
    
    // UITableViewDataSource 메서드
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFoodItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = filteredFoodItems[indexPath.row]
        cell.textLabel?.text = "\(item.name) - \(item.calories) kcal"
        return cell
    }
    
    // UISearchBarDelegate 메서드
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredFoodItems = foodItems
        } else {
            filteredFoodItems = foodItems.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredFoodItems = foodItems
        tableView.reloadData()
    }
}
