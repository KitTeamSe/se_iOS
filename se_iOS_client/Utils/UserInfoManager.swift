//
//  UserInfoManager.swift
//  se_iOS_client
//
//  Created by syon on 2021/05/22.
//

import UIKit
import Alamofire

struct UserInfoKey {
    static let loginId = "ID"
}

class UserInfoManager {
    let ud = UserDefaults.standard
    
    var loginId: String? {
        get {
            return UserDefaults.standard.string(forKey: UserInfoKey.loginId)
        }
        set (v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.loginId)
            ud.synchronize()
        }
    }
    
    var myAccountId: Int? {
        get{
            return UserDefaults.standard.integer(forKey: "accountId")
        }
        set (v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: "accountId")
            ud.synchronize()
        }
    }
    
    func login(id: String, pw: String, success: (()->Void)? = nil, fail: ((String)->Void)? = nil) {
        //API 호출
        
        let url = "http://swagger.se-testboard.duckdns.org/api/v1/signin"
        let param: Parameters = [
            "id":  id,
            "pw":  pw
        ]
        
        //API 호출 결과 처리
        let call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default)
        call.responseJSON { res in
            let result = try! res.result.get()
            guard let jsonObject = result as? NSDictionary else {
                fail?("오류:\(result)")
                return
            }
            if jsonObject["status"] is Int{
                let resultCode = jsonObject["status"] as! Int
                if resultCode == 200 {
                    
                    
                    self.ud.set(id, forKey: "loginId")
                    print(self.ud.string(forKey: "loginId")!)
                    
                    let temp = jsonObject["data"] as? NSDictionary
                    let accessToken = temp?.value(forKey: "token") as! String
                    
                    let tk = TokenUtils()
                    tk.save("kit.cs.ailab.syonKim.se-iOS-client", account: "accessToken", value: accessToken)
                    
                    //AccessToken 잘 왔나 확인
                    if let accessToken = tk.load("kit.cs.ailab.syonKim.se-iOS-client", account: "accessToken") {
                        print("accessToken = \(accessToken)")
                    } else {
                        print("accessToken is nil")
                    }
                    
                    success?()
                } else {
                    let msg = (jsonObject["message"] as? String) ?? "로그인 실패"
                    fail?(msg)
                }
            }
        }
    }
    
    func getMyAcoount(success: (()->Void)? = nil, fail: ((String)->Void)? = nil) {
        //self.indicatorView.startAnimating()
        let url = "http://swagger.se-testboard.duckdns.org/api/v1/account/my"
        let tokenUtils = TokenUtils()
        let header = tokenUtils.getAuthorizationHeader()
        
        let call = AF.request(url, encoding: JSONEncoding.default, headers: header)
        
        call.responseJSON { res in
            let result = try! res.result.get()
            guard let jsonObject = result as? NSDictionary else {
                fail?("오류:\(result)")
                return
            }
            if jsonObject["status"] is Int {
                let resultCode = jsonObject["status"] as! Int
                if resultCode == 200 {
                    print("status 부르기 성공")
                    //var temp: NSDictionary! = nil
                    let temp = jsonObject["data"] as? NSDictionary
                    if let accountId = temp?.value(forKey: "accountId") as? Int {
                        self.ud.set(accountId, forKey: "accountId")
                        print("accountId 부르기 성공")
                        print(accountId)
                    }
                }
               
                success?()
            } else {
                let msg = (jsonObject["message"] as? String) ?? "개인정보 불러오기 실패"
                fail?(msg)
            }
        }
        //self.indicatorView.stopAnimating()
    }
}
