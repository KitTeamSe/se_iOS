//
//  MypageViewController.swift
//  se_iOS_client
//
//  Created by syon on 2021/05/19.
//

import UIKit
import Alamofire

class MypageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
     
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var originPwField: UITextField!
    @IBOutlet weak var newPwField: UITextField!
    @IBOutlet weak var newPwCheckField: UITextField!
    @IBOutlet weak var originNicknameField: UITextField!
    @IBOutlet weak var newNicknameField: UITextField!
    @IBOutlet weak var informationOpenAgreeField: UITextField!
    @IBOutlet weak var btnPostMyAccount: UIButton!
    
    @IBOutlet weak var tagTableView: UITableView!
    
    @IBOutlet weak var myTagListField: UILabel!
    
    @IBOutlet weak var setMyTagField: UITextField!
    
    @IBOutlet weak var btnAddMyTag: UIButton!
    @IBOutlet weak var btnDeleteMyTag: UIButton!
    
    
    var checkForm: Bool?
    
    var pageSize: Int = 0
    var receiveTagList: [Tag] = []
    var emptyCheck: Bool?
    
    var receiveMyTagList: [Tag] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.string(forKey: "loginId") == nil {
            dismissAlert("로그인 후 이용 가능합니다.")
        } else {
            alert("반갑습니다. \(String(describing: UserDefaults.standard.string(forKey: "loginId")!))님.")
            idField.text! = UserDefaults.standard.string(forKey: "loginId")!
            idField.isUserInteractionEnabled = false
            getMyAcoount()
            getTagList()
            getMyTagList()
            self.tagTableView.dataSource = self
            self.tagTableView.delegate = self
            setMyTagField.delegate = self
        }
        hideKeyboard()
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
                    if let nickname = temp?.value(forKey: "nickname") as? String {
                        self.originNicknameField.text! = nickname
                    }
                    if let informationOpenAgree = temp?.value(forKey: "informationOpenAgree") as? String {
                        self.informationOpenAgreeField.text! = informationOpenAgree
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
    
    @IBAction func postMyAccount(_ sender: Any) {
        let id: String = UserDefaults.standard.string(forKey: "loginId")!
        let originPw: String = self.originPwField.text!
        let newPw: String = self.newPwField.text!
        let newPwCheck: String = self.newPwCheckField.text!
        let nickname: String = self.newNicknameField.text!
        let informationOpenAgree: String = self.informationOpenAgreeField.text!
        checkForm = false
        
        if checkPw(pwd: originPw) == false {
            self.alert("변경 전 비밀번호가 맞지 않습니다.")
        } else if isValidPassword(pwd: newPw) == false && self.newPwField.text != "" {
            self.alert("비밀번호 형식이 맞지 않습니다.")
        } else if newPw != newPwCheck && self.newPwCheckField.text != "" {
            self.alert("변경 후 비밀번호와 비밀번호 확인이 일치하지 않습니다.")
        } else if isValidNickname(nickName: nickname) == false && self.newNicknameField.text != "" {
            self.alert("닉네임이 형식에 맞지 않습니다.")
        } else if isValidInformationOpenAgree(informationOpenAgree: informationOpenAgree) == false && self.informationOpenAgreeField.text != "" {
            self.alert("정보제공 동의는 AGREE 또는 DISAGREE로 입력바랍니다.")
        } else {
            checkForm = true
        }
        
        if checkForm == true {
            var param: Parameters?
            
            if newPw != "" && nickname != "" && informationOpenAgree != "" {
                param = [
                    "id"                    : id,
                    "password"              : newPw,
                    "nickname"              : nickname,
                    "informationOpenAgree"  : informationOpenAgree
                ]
            } else if newPw == "" && nickname != "" && informationOpenAgree != "" {
                param = [
                    "id"                    : id,
                    "nickname"              : nickname,
                    "informationOpenAgree"  : informationOpenAgree
                ]
            } else if newPw != "" && nickname == "" && informationOpenAgree != "" {
                param = [
                    "id"                    : id,
                    "password"              : newPw,
                    "informationOpenAgree"  : informationOpenAgree
                ]
            } else if newPw != "" && nickname != "" && informationOpenAgree == "" {
                param = [
                    "id"                    : id,
                    "password"              : newPw,
                    "nickname"              : nickname
                ]
            } else if newPw == "" && nickname == "" && informationOpenAgree != "" {
                param = [
                    "id"                    : id,
                    "informationOpenAgree"  : informationOpenAgree
                ]
            } else if newPw == "" && nickname != "" && informationOpenAgree == "" {
                param = [
                    "id"                    : id,
                    "nickname"              : nickname
                ]
            } else if newPw != "" && nickname == "" && informationOpenAgree == "" {
                param = [
                    "id"                    : id,
                    "password"              : newPw
                ]
            }
            
            let url = "http://swagger.se-testboard.duckdns.org/api/v1/account"
            let tokenUtils = TokenUtils()
            let header = tokenUtils.getAuthorizationHeader()
            let call = AF.request(url, method: HTTPMethod.put, parameters: param, encoding: JSONEncoding.default, headers: header)
            
            call.responseJSON { res in
                guard let jsonObject = try! res.result.get() as? [String: Any] else {
                    self.alert("서버 호출 과정 중 오류가 발생했습니다.")
                    return
                }
                if jsonObject["status"] is Int {
                    let resultCode = jsonObject["status"] as! Int
                    if resultCode == 200 {
                        UserDefaults.standard.removeObject(forKey: "loginId")
                        UserDefaults.standard.removeObject(forKey: "loginPw")
                        UserDefaults.standard.synchronize()
                        
                        let tokenUtils = TokenUtils()
                        tokenUtils.delete("kit.cs.ailab.syonKim.se-iOS-client", account: "accessToken")
                        self.dismissAlert("회원정보 수정에 성공했습니다. 다시 로그인해 주세요.")
                    } else {
                        let errorMsg = jsonObject["message"] as! String
                        self.alert("\(errorMsg)")
                    }
                }
            }
        }
        
    }
    

    
    func checkPw(pwd: String) -> Bool {
        if originPwField.text! == UserDefaults.standard.string(forKey: "loginPw")! {
            return true
        } else {
            return false
        }
    }
    
    func isValidPassword(pwd: String) -> Bool {
        let passwordRegEx = "^[a-zA-Z0-9!_@$%^&+=]{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: pwd)
    }
    
    func isValidNickname(nickName: String) -> Bool {
        let nickNameRegEx = "[가-힣A-Za-z0-9]{2,20}"
        let nickNameTest = NSPredicate(format: "SELF MATCHES %@", nickNameRegEx)
        return nickNameTest.evaluate(with: nickName)
    }
    
    func isValidInformationOpenAgree(informationOpenAgree: String) -> Bool {
        if informationOpenAgreeField.text == "AGREE" || informationOpenAgreeField.text == "DISAGREE" {
            return true
        } else {
            return false
        }
    }
    
    func getTagList(success: (()->Void)? = nil, fail: ((String)->Void)? = nil) {
        //self.indicatorView.startAnimating()
        let url = "http://swagger.se-testboard.duckdns.org/api/v1/tag?direction=ASC&page=1&size=50"
        let tokenUtils = TokenUtils()
        let header = tokenUtils.getAuthorizationHeader()
        
        let call = AF.request(url, encoding: JSONEncoding.default, headers: header)
        self.receiveTagList = []
        
        call.responseJSON { res in
            let result = try! res.result.get()
            guard let jsonObject = result as? NSDictionary else {
                fail?("오류:\(result)")
                return
            }
            if jsonObject["status"] is Int {
                let resultCode = jsonObject["status"] as! Int
                if resultCode == 200 {
                    let temp = jsonObject["data"] as? NSDictionary
                    self.emptyCheck = false
                    if let temp2 = temp?.value(forKey: "content") as? [Any] {
                        print(self.pageSize)
                        self.pageSize = temp2.count
                        for numbers in 0..<temp2.count {
                            let temp3 = temp2[numbers] as? [String: Any]
                            let tag = Tag()
                            tag.tagId = temp3?["tagId"] as? Int
                            tag.tagName = temp3?["text"] as? String
                            self.receiveTagList.append(tag)
                        }
                    }
                    self.tagTableView.reloadData()
                    success?()
                }
            } else {
                let msg = (jsonObject["message"] as? String) ?? "개인정보 불러오기 실패"
                print(msg)
            }
        }
        //self.indicatorView.stopAnimating()
    }
    
    func getMyTagList(success: (()->Void)? = nil, fail: ((String)->Void)? = nil) {
        
        //self.indicatorView.startAnimating()
        let url = "http://swagger.se-testboard.duckdns.org/api/v1/tag-listen/account/my"
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
                    if let temp = jsonObject["data"] as? [Any] {
        
                        for numbers in 0..<temp.count {
                            let temp2 = temp[numbers] as? [String: Any]
                            let tag = Tag()
                            tag.tagId = temp2?["tagId"] as? Int
                            tag.tagListeningId = temp2?["tagListeningId"] as? Int
                            print(tag.tagListeningId!)
                            self.receiveMyTagList.append(tag)
                            if numbers == 0 {
                                self.myTagListField.text! = String(tag.tagId!)
                            } else {
                                self.myTagListField.text! = self.myTagListField.text! + ", " + String(tag.tagId!)
                            }
                        }
                    }
                    success?()
                }
            } else {
                let msg = (jsonObject["message"] as? String) ?? "개인정보 불러오기 실패"
                print(msg)
            }
        }
        //self.indicatorView.stopAnimating()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.pageSize > 0 {
            return self.pageSize
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TagTableViewCell = tagTableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath) as! TagTableViewCell
        if self.emptyCheck == false {
            cell.tagIdField.text! = String(self.receiveTagList[indexPath.row].tagId!)
            cell.tagNameField.text! = self.receiveTagList[indexPath.row].tagName!
        } else {
            cell.tagIdField.text! = ""
            cell.tagNameField.text! = "태그가 없습니다."
        }
        return cell
    }
    
    func checkMaxLength(textField: UITextField!, maxLength: Int) {
        if (textField.text!.count > maxLength) {
            textField.deleteBackward()
        }
    }

    @IBAction func textDidChanged(_ sender: Any) {
        checkMaxLength(textField: setMyTagField, maxLength: 1)
    }
    
    @IBAction func btnAddMyTag(_ sender: Any) {
        if setMyTagField.text != nil {
            let myTag : Int = Int(setMyTagField.text!)!
            let param: Parameters = [
                "tagId"                 : myTag
            ]
            
            let url = "http://swagger.se-testboard.duckdns.org/api/v1/tag-listen"
            let tokenUtils = TokenUtils()
            let header = tokenUtils.getAuthorizationHeader()
            
            let call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
            
            call.responseJSON { res in
                let result = try! res.result.get()
                guard let jsonObject = result as? NSDictionary else {
                    return
                }
                if jsonObject["status"] is Int {
                    let resultCode = jsonObject["status"] as! Int
                    if resultCode == 201 {
                        if let okMsg = jsonObject["message"] as? String {
                            self.alert(okMsg)
                            //self.myTagListField.text = self.myTagListField.text! + ", " + String(myTag)
                            self.getMyTagList()
                        }
                    }
                } else {
                    let msg = (jsonObject["message"] as? String) ?? "등록 실패"
                    self.alert(msg)
                }
            }
        }
    }
    
    @IBAction func btnDeleteMyTag(_ sender: Any) {
        if setMyTagField.text != nil {
            let myTag : Int = Int(setMyTagField.text!)!
            
            for numbers in 0..<receiveMyTagList.count {
                if receiveMyTagList[numbers].tagId == myTag {
                    let myListenTagNum = receiveMyTagList[numbers].tagListeningId!
                    let url = "http://swagger.se-testboard.duckdns.org/api/v1/tag-listen/" + String(myListenTagNum)
                    print("efefefefefefef")
                    print(myListenTagNum)
                    let tokenUtils = TokenUtils()
                    let header = tokenUtils.getAuthorizationHeader()
                    
                    let call = AF.request(url, method: .delete, encoding: JSONEncoding.default, headers: header)
                    
                    call.responseJSON { res in
                        let result = try! res.result.get()
                        guard let jsonObject = result as? NSDictionary else {
                            return
                        }
                        if jsonObject["status"] is Int {
                            let resultCode = jsonObject["status"] as! Int
                            if resultCode == 200 {
                                if let okMsg = jsonObject["message"] as? String {
                                    self.alert(okMsg)
                                    self.getMyTagList()
                                }
                            }
                        } else {
                            let msg = (jsonObject["message"] as? String) ?? "등록 실패"
                            self.alert(msg)
                        }
                    }
                }
            }
        }
    }
}
