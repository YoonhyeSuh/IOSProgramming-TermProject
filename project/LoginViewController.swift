//
//  ViewController.swift
//  project
//
//  Created by yhSuh on 2024/06/10.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    
    @IBOutlet weak var UserEmail: UITextField!
    
    @IBOutlet weak var UserPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = UserEmail.text else { return }
        guard let pw = UserPassword.text else { return }
                
        Auth.auth().signIn(withEmail: email, password: pw) { [self] authResult, error in
            if authResult == nil {
                print("로그인 실패")
                if let errorCode = error {
                        print(errorCode)
                    }
                }else if authResult != nil {
                    print("로그인 성공")
                }
                // 로그인 성공 시 DietViewController로 이동
            guard let DietViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") else { return }
              self.navigationController?.pushViewController(DietViewController, animated: true)
            }
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
           // 회원가입 화면으로 이동
           if let registerVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController {
               self.navigationController?.pushViewController(registerVC, animated: true)
           }
    }
}

