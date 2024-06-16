//
//  FoodTableViewCell.swift
//  project
//
//  Created by yhSuh on 2024/06/17.
//

import UIKit

//식단기록 tableview 커스텀 셀 클래스 생성
class FoodTableViewCell: UITableViewCell {
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var mealTimeLabel: UILabel!
}

