//
//  LoginViewController.swift
//  se_iOS_client
//
//  Created by syon on 2021/04/03.
//

import UIKit
import Alamofire


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //View
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnAutoLogin: UIButton!
    @IBOutlet weak var btnFindId: UIButton!
    @IBOutlet weak var btnGuest: UIButton!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var btnCheckBox: UIButton!
    
    
    let seColor = #colorLiteral(red: 0.3450980392, green: 0.7490196078, blue: 0.8823529412, alpha: 1)
    var radius: CGFloat!
    var borderWidth: CGFloat!
    
    let uinfo = UserInfoManager()
    var isCalling = false
    var isCheck = false
    var isLogin = false
    
    
    let temp = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRadius(radius: 4)
        setBorderColor()
        setBorderWidth(borderWidth: 1)
        imageTintColorSettings()
        print("a")
        
        
        
        if let autoId = UserDefaults.standard.string(forKey: "loginId") {
            self.uinfo.login(id: autoId, pw: UserDefaults.standard.string(forKey: "loginPw")!, success: {
                self.indicatorView.stopAnimating()
                
                self.isLogin = true
                
                self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "loginSegue", sender: self)
                
            }, fail: { msg in
                self.indicatorView.stopAnimating()
                self.isCalling = false
                self.alert(msg)
            })
            
        }
        
        // 키 체인 저장 여부 확인을 위한 임시 코드
        /* let tk = TokenUtils()
         if let accessToken = tk.load("kit.cs.ailab.syonKim.se-iOS-client", account: "accessToken") {
         print("accessToken = \(accessToken)")
         } else {
         print("accessToken is nil")
         } */
        
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
            
            UserDefaults.standard.set(id, forKey: "loginId")
            UserDefaults.standard.set(pw, forKey: "loginPw")
            
            self.isLogin = true
            self.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "loginSegue", sender: self)
            
        }, fail: { msg in
            self.indicatorView.stopAnimating()
            self.isCalling = false
            self.alert(msg)
        })
    }
    
    @IBAction func btnAutoLogin(_ sender: Any) {
        
        if isCheck == false {
            let image = UIImage(named: "checkbox.svg")?.withRenderingMode(.alwaysTemplate)
            btnCheckBox.setBackgroundImage(image, for: .normal)
            isCheck = true
        } else if isCheck == true {
            let image = UIImage(named: "box.svg")?.withRenderingMode(.alwaysTemplate)
            btnCheckBox.setBackgroundImage(image, for: .normal)
            isCheck = false
        }
    }
    
    
    
    func setRadius(radius: CGFloat) {
        btnLogin.layer.cornerRadius = radius
        btnSignUp.layer.cornerRadius = radius
        btnAutoLogin.layer.cornerRadius = radius
        btnFindId.layer.cornerRadius = radius
        btnGuest.layer.cornerRadius = radius
    }
    
    func setBorderColor(){
        btnLogin.layer.borderColor = seColor.cgColor
        btnSignUp.layer.borderColor = seColor.cgColor
        btnAutoLogin.layer.borderColor = seColor.cgColor
        btnFindId.layer.borderColor = seColor.cgColor
        btnGuest.layer.borderColor = seColor.cgColor
    }
    
    func setBorderWidth(borderWidth: CGFloat){
        btnLogin.layer.borderWidth = borderWidth
        btnSignUp.layer.borderWidth = borderWidth
        btnFindId.layer.borderWidth = borderWidth
        btnGuest.layer.borderWidth = borderWidth
    }
    
    func imageTintColorSettings() {
        let image = UIImage(named: "box.svg")?.withRenderingMode(.alwaysTemplate)
        btnCheckBox.setBackgroundImage(image, for: .normal)
        
        let image2 = UIImage(named: "checkbox.svg")?.withRenderingMode(.alwaysTemplate)
        btnCheckBox.setBackgroundImage(image2, for: .selected)
        
        btnCheckBox.tintColor = seColor
    }    
}
