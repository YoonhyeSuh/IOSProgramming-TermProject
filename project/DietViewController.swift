//
//  DietViewController.swift
//  project
//
//  Created by yhSuh on 2024/06/16.
//

import UIKit
import Firebase

// DietViewController 클래스는 UIViewController를 상속받고, UITableViewDataSource 및 UITableViewDelegate 프로토콜을 채택합니다.
class DietViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // 스토리보드에서 연결된 UITableView 및 UILabel 아웃렛
    @IBOutlet weak var dietTableView: UITableView!
    @IBOutlet weak var caloriesLabel: UILabel!

    // FoodItem 객체 배열을 저장할 변수
    var foods: [FoodItem] = []
    
    // 뷰가 로드될 때 호출되는 메소드
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UITableView의 delegate 및 dataSource 설정
        dietTableView.delegate = self
        dietTableView.dataSource = self

        // 데이터 가져오기
        fetchFoods()
    }
    
    // 뷰가 나타날 때마다 호출되는 메소드
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFoods()
    }
    
    // 테이블 뷰 편집 모드를 토글하는 액션
    @IBAction func editingTableViewRow(_ sender: UIBarButtonItem) {
        if dietTableView.isEditing {
            sender.title = "Edit"
            dietTableView.isEditing = false
        } else {
            sender.title = "Done"
            dietTableView.isEditing = true
        }
    }
    
    // 새로운 다이어트 항목을 추가하는 액션
    @IBAction func addingDiet(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "GotoDetail", sender: nil)
    }
    
    // Firebase Firestore에서 음식 데이터를 가져오는 메소드
    func fetchFoods() {
        let db = Firestore.firestore()
        db.collection("foods").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            // 문서 데이터를 FoodItem 객체 배열로 변환
            self.foods = snapshot?.documents.compactMap { document in
                let data = document.data()
                guard let id = document.documentID as String?,
                      let name = data["name"] as? String,
                      let calories = data["calories"] as? String,
                      let mealTime = data["mealTime"] as? String,
                      let imageUrl = data["imageUrl"] as? String else {
                    return nil
                }
                return FoodItem(id: id, name: name, calories: calories, mealTime: mealTime, imageUrl: imageUrl)
            } ?? []
            
            // 테이블 뷰를 리로드하고 총 칼로리를 업데이트
            self.dietTableView.reloadData()
            self.updateTotalCalories()
        }
    }

    // 총 칼로리를 업데이트하는 메소드
    func updateTotalCalories() {
        let totalCalories = foods.reduce(0) { $0 + (Int($1.calories) ?? 0) }
        caloriesLabel.text = "Total Calories: \(totalCalories)"
    }
    
    // UITableViewDataSource 프로토콜 구현
    
    // 섹션당 행의 수를 반환
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
    }
    
    // 특정 행에 대한 셀을 반환
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodTableViewCell", for: indexPath) as? FoodTableViewCell else {
            return UITableViewCell()
        }
        let food = foods[indexPath.row]
        cell.nameLabel.text = food.name
        cell.caloriesLabel.text = food.calories
        cell.mealTimeLabel.text = food.mealTime
        
        // 이미지 로드
        if let url = URL(string: food.imageUrl) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, error == nil {
                    DispatchQueue.main.async {
                        cell.foodImageView.image = UIImage(data: data)
                    }
                }
            }
            task.resume()
        }

        return cell
    }
    
    // UITableViewDelegate 프로토콜 구현
    
    // 특정 행을 편집할 수 있는지 여부를 반환
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // 특정 행이 삭제되었을 때 호출되는 메소드
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let food = foods[indexPath.row]
            let db = Firestore.firestore()
            db.collection("foods").document(food.id).delete { error in
                if let error = error {
                    print("Error deleting document: \(error)")
                } else {
                    self.foods.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.updateTotalCalories()
                }
            }
        }
    }
    
    // 행이 이동되었을 때 호출되는 메소드
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedFood = foods.remove(at: fromIndexPath.row)
        foods.insert(movedFood, at: to.row)
    }
}


