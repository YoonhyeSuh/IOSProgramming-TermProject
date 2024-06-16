//
//  ViewController.swift
//  project
//
//  Created by yhSuh on 2024/06/10.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    // 이메일 입력 텍스트 필드
    @IBOutlet weak var UserEmail: UITextField!
    
    // 비밀번호 입력 텍스트 필드
    @IBOutlet weak var UserPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // 로그인 버튼이 눌렸을 때 호출되는 함수
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // 이메일과 비밀번호 입력값을 가져옴
        guard let email = UserEmail.text else { return }
        guard let pw = UserPassword.text else { return }
        
        // Firebase의 Auth를 사용하여 로그인 시도
        Auth.auth().signIn(withEmail: email, password: pw) { [self] authResult, error in
            if authResult == nil {
                print("로그인 실패")
                if let errorCode = error {
                    print(errorCode)
                }
            } else if authResult != nil {
                print("로그인 성공")
            }
            // 로그인 성공 시 DietViewController로 이동
            guard let DietViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") else { return }
            self.navigationController?.pushViewController(DietViewController, animated: true)
        }
    }
    
    // 회원가입 버튼이 눌렸을 때 호출되는 함수
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        // 회원가입 화면으로 이동
        if let registerVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController {
            self.navigationController?.pushViewController(registerVC, animated: true)
        }
    }
}

