//
//  DietViewController.swift
//  project
//
//  Created by yhSuh on 2024/06/16.
//

import UIKit
import Firebase

class DietViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var dietTableView: UITableView!
    @IBOutlet weak var caloriesLabel: UILabel!

    var foods: [FoodItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dietTableView.delegate = self
        dietTableView.dataSource = self

        fetchFoods()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFoods()
    }
    
    @IBAction func editingTableViewRow(_ sender: UIBarButtonItem) {
        if dietTableView.isEditing {
            sender.title = "Edit"
            dietTableView.isEditing = false
        } else {
            sender.title = "Done"
            dietTableView.isEditing = true
        }
    }
    
    @IBAction func addingDiet(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "GotoDetail", sender: nil)
    }
    
    func fetchFoods() {
        let db = Firestore.firestore()
        db.collection("foods").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
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
            
            self.dietTableView.reloadData()
            self.updateTotalCalories()
        }
    }

    
    func updateTotalCalories() {
        let totalCalories = foods.reduce(0) { $0 + (Int($1.calories) ?? 0) }
        caloriesLabel.text = "Total Calories: \(totalCalories)"
    }
    
    //UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
    }
    
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
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
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
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedFood = foods.remove(at: fromIndexPath.row)
        foods.insert(movedFood, at: to.row)
    }
}

