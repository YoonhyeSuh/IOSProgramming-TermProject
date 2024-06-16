//
//  AddDietViewController.swift
//  project
//
//  Created by yhSuh on 2024/06/16.
//

import UIKit
import Firebase

// AddDietViewController: 음식 다이어트 정보를 추가하는 뷰 컨트롤러
class AddDietViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // 아울렛 변수: 인터페이스 빌더에서 연결된 UI 요소들
    @IBOutlet weak var caloriesTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var timePickerView: UIPickerView!
    @IBOutlet weak var foodImageView: UIImageView!
    
    // 식사 시간 배열
    let mealTimes = ["아침", "점심", "저녁", "간식1", "간식2", "간식3"]
    var selectedMealTime: String? // 선택된 식사 시간
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIPickerView 델리게이트 및 데이터 소스 설정
        timePickerView.delegate = self
        timePickerView.dataSource = self
        
        // 이미지 뷰에 탭 제스처 인식기 추가
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        foodImageView.isUserInteractionEnabled = true
        foodImageView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    // 이미지 뷰가 탭되었을 때 호출되는 함수
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 이미지 선택이 완료되었을 때 호출되는 함수
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            foodImageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    // UIPickerView 데이터 소스 함수: 컴포넌트 개수
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerView 데이터 소스 함수: 행 개수
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mealTimes.count
    }
    
    // UIPickerView 델리게이트 함수: 행의 제목
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mealTimes[row]
    }
    
    // UIPickerView 델리게이트 함수: 행이 선택되었을 때 호출
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedMealTime = mealTimes[row]
    }
    
    // 저장 버튼이 눌렸을 때 호출되는 함수
    @IBAction func savingFood(_ sender: UIButton) {
        // 모든 필드가 채워졌는지 확인
        guard let name = nameTextField.text, !name.isEmpty,
              let calories = caloriesTextField.text, !calories.isEmpty,
              let mealTime = selectedMealTime,
              let image = foodImageView.image else {
            // 모든 필드가 채워지지 않은 경우 경고 창 표시
            let alert = UIAlertController(title: "Error", message: "모든 필드를 채워주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // Firebase에 데이터 저장
        let db = Firestore.firestore()
        let storage = Storage.storage()
        
        // 이미지 데이터를 JPEG 형식으로 압축
        let imageData = image.jpegData(compressionQuality: 0.8)
        // Firebase Storage에 이미지를 저장할 참조 생성
        let imageRef = storage.reference().child("foodImages").child("\(UUID().uuidString).jpg")
        
        // 이미지를 Firebase Storage에 업로드
        imageRef.putData(imageData!, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error)")
                return
            }
            
            // 업로드가 성공하면 다운로드 URL을 가져옴
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error)")
                    return
                }
                
                guard let url = url else {
                    print("Download URL is nil")
                    return
                }
                
                // 음식 데이터를 Firestore에 저장
                let foodData: [String: Any] = [
                    "name": name,
                    "calories": calories,
                    "mealTime": mealTime,
                    "imageUrl": url.absoluteString
                ]
                
                db.collection("foods").addDocument(data: foodData) { error in
                    if let error = error {
                        print("Error saving food data: \(error)")
                    } else {
                        print("Food data saved successfully!")
                    }
                }
            }
        }
    }
}

