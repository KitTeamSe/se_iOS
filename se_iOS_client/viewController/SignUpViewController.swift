//
//  SignUpViewController.swift
//  se_iOS_client
//
//  Created by syon on 2021/04/04.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var pwCheckField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var nicknameField: UITextField!
    @IBOutlet weak var studentIdField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var termsAgreeSwitch: UISwitch!
    
    let pwRegex = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,50}"
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    
    
    var termsAgree: Bool!
    var checkForm: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboard()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnSignUp(_ sender: Any) {
        let id: String = self.idField.text!
        let pw: String = self.pwField.text!
        let pwCheck: String = self.pwCheckField.text!
        let name: String = self.nameField.text!
        let nickname: String = self.nicknameField.text!
        let studentId: String = self.studentIdField.text!
        let phoneNumber: String = self.phoneNumberField.text!
        let email: String = self.emailField.text!
        
        checkForm = false
        
        if id.count < 5 {
            alarm(msg: "ID는 5자 이상입니다.")
        } else if isValidPassword(pwd: pw) == false {
            alarm(msg: "비밀번호 형식이 맞지 않습니다.")
        } else if pw != pwCheck {
            alarm(msg: "비밀번호와 비밀번호 확인이 일치하지 않습니다.")
        } else if isValidName(name: name) == false {
            alarm(msg: "이름이 형식에 맞지 않습니다.")
        } else if isValidNickname(nickName: nickname) == false {
            alarm(msg: "닉네임이 형식에 맞지 않습니다.")
        } else if isValidEmail(email: email) == false {
            alarm(msg: "이메일이 형식에 맞지 않습니다.")
        } else {
            if termsAgreeSwitch.isOn {
                termsAgree = true
            } else {
                termsAgree = false
            }
            checkForm = true
        }
        
        if checkForm == true {
            Account (account_id: nil, id: id, password: pw, name: name, nickname: nickname, student_id: studentId, type: nil, phone_number: phoneNumber, email: email, last_signin_ip: nil, information_open_agree: termsAgree)
            
            //여기에 회원 정보 전달. API go, 통신 잘 됐으면 회원가입 완료 alarm 띄우기.
            //
            //
        }
        
        
        
    }
    
    func alarm(msg: String) {
        let alert = UIAlertController(title: "회원가입 실패", message: msg, preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
        present(alert, animated: true, completion: nil)
        alert.addAction(ok)
    }
    
    func isValidPassword(pwd: String) -> Bool {
        let passwordRegEx = "^[a-zA-Z0-9!_@$%^&+=]{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: pwd)
    }
    
    func isValidName(name: String) -> Bool {
        let nameRegEx = "[가-힣]{2,4}"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: name)
    }
    
    func isValidNickname(nickName: String) -> Bool {
        let nickNameRegEx = "[가-힣A-Za-z0-9]{2,7}"
        let nickNameTest = NSPredicate(format: "SELF MATCHES %@", nickNameRegEx)
        return nickNameTest.evaluate(with: nickName)
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

}
