//
//  RegisterViewController.swift
//  project
//
//  Created by yhSuh on 2024/06/14.
//

import UIKit
import FirebaseAuth
import FirebaseCore

class RegisterViewController: UIViewController {

    // 기본 뷰, 모든 하위 뷰를 포함하는 컨테이너
    lazy var baseView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
        
    // 스택 뷰, 하위 뷰들을 수직으로 정렬하고 균등하게 분배
    lazy var stackView: UIStackView = {
        var view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fillEqually
        view.alignment = .fill
        view.spacing = 20
        return view
    }()
    
    // 타이틀 라벨, "Register" 텍스트를 가운데 정렬
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Register"
        label.textAlignment = .center
        return label
    }()
    
    // 이메일 입력 텍스트 필드
    lazy var emailTextField: UITextField = {
        var view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Write your email"
        view.borderStyle = .roundedRect
        return view
    }()
    
    // 비밀번호 입력 텍스트 필드
    lazy var passwordTextField: UITextField = {
        var view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Write your password"
        view.borderStyle = .roundedRect
        return view
    }()
    
    // 회원가입 버튼
    lazy var RegisterBtn: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        return button
    }()
    
    // 이메일 정규 표현식 패턴
    let emailPattern = "^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*\\.[a-zA-Z]{2,3}$"
    // 비밀번호 정규 표현식 패턴
    let passwordPattern = "^.*(?=^.{8,16}$)(?=.*\\d)(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$"
    var emailValid = false // 이메일 유효성 플래그
    var passwordValid = false // 비밀번호 유효성 플래그
    var allValid = false // 전체 유효성 플래그
    
    // 뷰가 로드될 때 호출
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        view.backgroundColor = .white
        addViews()
        applyConstraints()
        addTarget()
//        addBackButton()
    }

    // 뷰 추가 메서드
    fileprivate func addViews() {
        view.addSubview(baseView)
        baseView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(RegisterBtn)
    }
    
    // 제약 조건 설정 메서드
    fileprivate func applyConstraints() {
        let baseViewConstraints = [
            baseView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            baseView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            baseView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            baseView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ]
    
        let stackViewConstraints = [
            stackView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 30),
            stackView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -30),
        ]
        
        let emailTfConstraints = [
            emailTextField.heightAnchor.constraint(equalToConstant: 50)
        ]
        NSLayoutConstraint.activate(baseViewConstraints)
        NSLayoutConstraint.activate(stackViewConstraints)
        NSLayoutConstraint.activate(emailTfConstraints)
    }
        
    // 타겟 설정 메서드
    fileprivate func addTarget() {
        RegisterBtn.addTarget(self, action: #selector(didTapRegisterButton(_:)), for: .touchUpInside)
        
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }

//    // 뒤로가기 버튼 추가 메서드
//    fileprivate func addBackButton() {
//        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(didTapBackButton(_:)))
//        navigationItem.leftBarButtonItem = backButton
//    }
//
//    // 뒤로가기 버튼 클릭 시 호출 메서드
//    @objc func didTapBackButton(_ sender: UIBarButtonItem) {
//        navigationController?.popViewController(animated: true)
//    }

    // 텍스트 유효성 검사 메서드
    fileprivate func isValid(text: String, pattern: String) -> Bool {
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        return pred.evaluate(with: text)
    }
    
    // 이메일 유효성 검사 메서드
    fileprivate func checkEmail() {
        if isValid(text: emailTextField.text!, pattern: emailPattern) {
            emailValid = true
        } else {
            emailValid = false
        }
    }
    
    // 비밀번호 유효성 검사 메서드
    fileprivate func checkPw() {
        if isValid(text: passwordTextField.text!, pattern: passwordPattern) {
            passwordValid = true
        } else {
            passwordValid = false
        }
    }
    
    // 전체 유효성 검사 메서드
    fileprivate func checkAll() {
        if emailValid && passwordValid {
            print("email, password Valid Success")
            allValid = true
        } else {
            print("email, password Valid Fail")
            allValid = false
        }
    }
    
    // 텍스트 필드 변경 시 호출 메서드
    @objc func textFieldDidChange(_ sender: UITextField) -> Bool {
        switch sender {
        case emailTextField:
            checkEmail()
        case passwordTextField:
            checkPw()
        default:
            break
        }
        checkAll()
        return true
    }
    
    // 회원가입 버튼 클릭 시 호출 메서드
    @objc func didTapRegisterButton(_ sender: UIButton) {
        print("회원가입 버튼 클릭")
        
        if let email = emailTextField.text {
            print("Email : ", email)
        }
        
        if let password = passwordTextField.text {
            print("Password : ", password)
        }
        
        if allValid {
            createUser()
            // 회원가입 성공 시 LoginViewController로 이동
                        if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                            self.navigationController?.pushViewController(loginVC, animated: true)
                        }
        }
    }
    
    // 사용자 생성 메서드
    fileprivate func createUser() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error)
            }
            
            if let result = result {
                print(result)
            }
        }
    }
}

