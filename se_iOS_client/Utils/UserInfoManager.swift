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
                    
                    let ud = UserDefaults.standard
                    
                    ud.set(id, forKey: "loginId")
                    print(ud.string(forKey: "loginId")!)
                    
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
}
