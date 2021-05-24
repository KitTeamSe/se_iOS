//
//  FreeboardViewController.swift
//  se_iOS_client
//
//  Created by syon on 2021/05/19.
//

import UIKit


class FreeboardViewController: UIViewController {

    @IBOutlet weak var btnLoginLogout: UIBarButtonItem!
    @IBOutlet weak var postTableView: UITableView!
    
    var isLogin: Bool!
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        //self.isLogin = appDelegate.isLogin!
        isLogin = false
        changeBtnLoginLogOut()
        
        super.viewDidLoad()
       
    }
    

    @IBAction func btnLoginLogout(_ sender: Any) {
        if isLogin == false {
            self.dismiss(animated: true)
        } else {
            isLogin = false
            changeBtnLoginLogOut()
            //로그아웃 코드
            logout()
        }
    }
    
    func changeBtnLoginLogOut() {
        if UserDefaults.standard.string(forKey: "loginId") != nil {
            btnLoginLogout.title = "로그아웃"
            isLogin = true

        } else {
            btnLoginLogout.title = "로그인"
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "loginId")
        UserDefaults.standard.removeObject(forKey: "loginPw")
        UserDefaults.standard.synchronize()
        
        let tokenUtils = TokenUtils()
        tokenUtils.delete("kit.cs.ailab.syonKim.se-iOS-client", account: "accessToken")

        dismissAlert("로그아웃 되었습니다.")
    }
    
 
}
