//
//  LoginViewController.swift
//  se_iOS_client
//
//  Created by syon on 2021/04/03.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController, UITextFieldDelegate, sendBackDelegate {
    
    //View
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnFindId: UIButton!
    @IBOutlet weak var btnFindPassword: UIButton!
    @IBOutlet weak var btnGuest: UIButton!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    let seColor = #colorLiteral(red: 0.3450980392, green: 0.7490196078, blue: 0.8823529412, alpha: 1)
    var radius: CGFloat!
    var borderWidth: CGFloat!
    
    let uinfo = UserInfoManager()
    var isCalling = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRadius(radius: 4)
        setBorderColor()
        setBorderWidth(borderWidth: 1)
        
        // 키 체인 저장 여부 확인을 위한 임시 코드
        let tk = TokenUtils()
        if let accessToken = tk.load("kr.co.rubypaper.MyMemory", account: "accessToken") {
            print("accessToken = \(accessToken)")
        } else {
            print("accessToken is nil")
        }
        
        self.view.bringSubviewToFront(self.indicatorView)
        hideKeyboard()
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        if self.isCalling == true {
            self.alert("응답을 기다리는 중입니다. \n잠시만 기다려 주세요.")
            return
        } else {
            self.isCalling = true
        }
        self.indicatorView.startAnimating()
        self.isCalling = false
        let id: String = self.idTextField.text!
        let pw: String = self.passwordTextField.text!
        
        self.uinfo.login(id: id, pw: pw, success: {
            self.indicatorView.stopAnimating()
            //성공 시 다음 화면 띄우기(세그웨이)
            self.alert("로그인 성공")
            
        }, fail: { msg in
            self.indicatorView.stopAnimating()
            self.isCalling = false
            self.alert(msg)
        })
    }
    
    
    
    func setRadius(radius: CGFloat) {
        btnLogin.layer.cornerRadius = radius
        btnSignUp.layer.cornerRadius = radius
        btnFindId.layer.cornerRadius = radius
        btnFindPassword.layer.cornerRadius = radius
        btnGuest.layer.cornerRadius = radius
        
    }
    
    func setBorderColor(){
        btnLogin.layer.borderColor = seColor.cgColor
        btnSignUp.layer.borderColor = seColor.cgColor
        btnFindId.layer.borderColor = seColor.cgColor
        btnFindPassword.layer.borderColor = seColor.cgColor
        btnGuest.layer.borderColor = seColor.cgColor
    }
    
    func setBorderWidth(borderWidth: CGFloat){
        btnLogin.layer.borderWidth = borderWidth
        btnSignUp.layer.borderWidth = borderWidth
        btnFindId.layer.borderWidth = borderWidth
        btnFindPassword.layer.borderWidth = borderWidth
        btnGuest.layer.borderWidth = borderWidth
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSignupView" {
            let signUpVC = segue.destination as! SignUpViewController
            signUpVC.data = true
            signUpVC.delegate = self
        }
    }
    
    func dataReceived(data: Bool) {
        self.alert("정상적으로 가입이 완료되었습니다.")
    }
    
}
