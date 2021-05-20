//
//  SignUpViewController.swift
//  se_iOS_client
//
//  Created by syon on 2021/04/04.
//

import UIKit
import Alamofire

protocol sendBackDelegate {
    func dataReceived(data: Bool)
}

class SignUpViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var pwCheckField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var nicknameField: UITextField!
    @IBOutlet weak var studentIdField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var questionField: UITextField!
    @IBOutlet weak var answerField: UITextField!
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    let pickerData = ["지도교수님의 이름은?", "지도교수님의 연구실 번호는?", "가장 기억에 남는 교수님은?", "나의 연구실 호수는?", "내가 졸업한 초등학교는?", "나의 첫 노트북의 제조사는?"]
    
    var checkForm: Bool!
    var questionId: Int64!
    var isCalling = false
    var delegate : sendBackDelegate?
    var data = true
    
    override func viewDidLoad() {
        sePickerView()
        dismissPickerView()
        super.viewDidLoad()
        
        self.view.bringSubviewToFront(self.indicatorView)
        hideKeyboard()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnSignUp(_ sender: Any) {
        self.indicatorView.startAnimating()
        isCalling = false
        
        let id: String = self.idField.text!
        let pw: String = self.pwField.text!
        let pwCheck: String = self.pwCheckField.text!
        let name: String = self.nameField.text!
        let nickname: String = self.nicknameField.text!
        let studentId: String = self.studentIdField.text!
        let phoneNumber: String = self.phoneNumberField.text!
        let email: String = self.emailField.text!
        let answer: String = self.answerField.text!
        
        checkForm = false
        
        if id.count < 5 {
            self.alert("ID는 5자 이상입니다.")
        } else if isValidPassword(pwd: pw) == false {
            self.alert("비밀번호 형식이 맞지 않습니다.")
        } else if pw != pwCheck {
            self.alert("비밀번호와 비밀번호 확인이 일치하지 않습니다.")
        } else if isValidName(name: name) == false {
            self.alert("이름이 형식에 맞지 않습니다.")
        } else if isValidNickname(nickName: nickname) == false {
            self.alert("닉네임이 형식에 맞지 않습니다.")
        } else if isValidEmail(email: email) == false {
            self.alert("이메일이 형식에 맞지 않습니다.")
        } else if isValidPhoneNumber(phoneNumber: phoneNumber) == false {
            self.alert("핸드폰번호가 형식에 맞지 않습니다.")
        } else if isValidStudentId(studentId: studentId) == false {
            self.alert("학번은 8자입니다.")
        } else if answer.count < 2 {
            self.alert("답변이 형식에 맞지 않습니다.")
        } else {
            checkForm = true
        }
        
        self.indicatorView.stopAnimating()
        
        if self.isCalling == true {
            self.alert("진행 중입니다. 잠시만 기다려주세요.")
            return
        } else {
            self.isCalling = true
        }
        
        if checkForm == true {
            let param: Parameters = [
                "answer"        : answer,
                "email"         : email,
                "id"            : id,
                "name"          : name,
                "nickname"      : nickname,
                "password"      : pw,
                "phoneNumber"   : phoneNumber,
                "questionId"    : questionId!,
                "studentId"     : studentId,
                "type"          : "STUDENT"
            ]
            let url = "http://swagger.se-testboard.duckdns.org/api/v1/signup"
            let call = AF.request(url, method: HTTPMethod.post, parameters: param, encoding: JSONEncoding.default)
            
            call.responseJSON { res in
                self.indicatorView.stopAnimating()
                guard let jsonObject = try! res.result.get() as? [String: Any] else {
                    self.isCalling = false
                    self.alert("서버 호출 과정 중 오류가 발생했습니다.")
                    return
                }
                
                if jsonObject["code"] is Int {
                    let resultCode = jsonObject["code"] as! Int
                    if resultCode == 201 {
                        self.delegate?.dataReceived(data: true)
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    self.isCalling = false
                    let errorMsg = jsonObject["message"] as! String
                    self.alert("오류 : \(errorMsg)")
                }
            }
        }
    }
    
    @objc func pickerExit() {
        self.view.endEditing(true)
    }
    
    func sePickerView() {
        let sePicker = UIPickerView()
        sePicker.delegate = self
        questionField.inputView = sePicker
    }
    
    func dismissPickerView() {
        let toolBar = UIToolbar(frame: CGRect(x:0, y:0, width:0, height:100))
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(pickerExit))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        questionField.inputAccessoryView = toolBar
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        questionField.text = pickerData[row]
        questionId = Int64(row) + 1
    }
    
    func isValidPassword(pwd: String) -> Bool {
        let passwordRegEx = "^[a-zA-Z0-9!_@$%^&+=]{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: pwd)
    }
    
    func isValidName(name: String) -> Bool {
        let nameRegEx = "[가-힣]{2,20}"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: name)
    }
    
    func isValidNickname(nickName: String) -> Bool {
        let nickNameRegEx = "[가-힣A-Za-z0-9]{2,20}"
        let nickNameTest = NSPredicate(format: "SELF MATCHES %@", nickNameRegEx)
        return nickNameTest.evaluate(with: nickName)
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func isValidPhoneNumber(phoneNumber: String) -> Bool {
        let phoneNumberRegEx = "[0-9]{11}"
        let phoneNumberTest = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegEx)
        return phoneNumberTest.evaluate(with: phoneNumber)
    }
    
    func isValidStudentId(studentId: String) -> Bool {
        let studentIdRegEx = "[0-9]{8}"
        let studentIdTest = NSPredicate(format: "SELF MATCHES %@", studentIdRegEx)
        return studentIdTest.evaluate(with: studentId)
    }


}
