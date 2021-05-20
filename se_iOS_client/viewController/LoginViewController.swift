//
//  LoginViewController.swift
//  se_iOS_client
//
//  Created by syon on 2021/04/03.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, sendBackDelegate {
    
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnFindId: UIButton!
    @IBOutlet weak var btnFindPassword: UIButton!
    @IBOutlet weak var btnGuest: UIButton!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let seColor = #colorLiteral(red: 0.3450980392, green: 0.7490196078, blue: 0.8823529412, alpha: 1)
    
    var radius: CGFloat!
    var borderWidth: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setRadius(radius: 4)
        setBorderColor()
        setBorderWidth(borderWidth: 1)
        
        hideKeyboard()
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
