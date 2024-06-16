//
//  FoodItem.swift
//  project
//
//  Created by yhSuh on 2024/06/16.
//

import Foundation

//식단기록에 필요한 데이터 구조체

struct FoodItem: Codable {
    let id: String
    let name: String
    let calories: String
    let mealTime: String
    let imageUrl: String
}
