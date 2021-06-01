//
//  UploadPostViewController.swift
//  se_iOS_client
//
//  Created by syon on 2021/05/25.
//

import UIKit
import Alamofire

class PostFormViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var titleField: UITextField!
    
    @IBOutlet weak var btnBold: UIButton!
    @IBOutlet weak var btnAlignLeft: UIButton!
    @IBOutlet weak var btnAlignRight: UIButton!
    @IBOutlet weak var btnAlignCenter: UIButton!
    @IBOutlet weak var btnAlignJustify: UIButton!
    @IBOutlet weak var btnPicture: UIButton!
    @IBOutlet weak var btnFile: UIButton!
    @IBOutlet weak var fontSizeTxtField: UITextField!
    
    @IBOutlet weak var textField: UITextView!
    
    
    @IBOutlet weak var anonymousNickname: UITextField!
    @IBOutlet weak var anonymousPassword: UITextField!
    @IBOutlet weak var btnCheckFile: UIButton!
    @IBOutlet weak var tagNumTextField: UITextField!
    
    @IBOutlet weak var btnCheckBox: UIButton!
    @IBOutlet weak var txtSecret: UILabel!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
    var delegate: SendDataDelegate?
    
    let seColor = #colorLiteral(red: 0.3450980392, green: 0.7490196078, blue: 0.8823529412, alpha: 1)
    var radius: CGFloat!
    var borderWidth: CGFloat!
    
    var isCheck : Bool?
    var isLogin : Bool?
    
    var tagList: [String] = []
    var tagId: Int = 0
    
    var isValid: Bool = false
        
    override func viewDidLoad() {
        isCheck = false
        
        setRadius(radius: 4)
        setBorderColor()
        setBorderWidth(borderWidth: 1.5)
        imageTintColorSettings()
        
        checkLogin()
        
        if isLogin == true {
            createTagPicker()
            createToolBar()
        } else {
            tagNumTextField.isUserInteractionEnabled = false
            alert("태그 등록 기능은 로그인이 필요합니다.")
        }
        
        super.viewDidLoad()
        hideKeyboard()
    }
    
    @IBAction func btnSecret(_ sender: Any) {
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
        titleField.layer.cornerRadius = radius
        textField.layer.cornerRadius = radius
        btnSubmit.layer.cornerRadius = radius
        txtSecret.layer.cornerRadius = radius
        btnCheckFile.layer.cornerRadius = radius
        anonymousNickname.layer.cornerRadius = radius
        anonymousPassword.layer.cornerRadius = radius
        tagNumTextField.layer.cornerRadius = radius
    }
    
    func setBorderColor(){
        titleField.layer.borderColor = seColor.cgColor
        textField.layer.borderColor = seColor.cgColor
        btnSubmit.layer.borderColor = seColor.cgColor
        btnCheckFile.layer.borderColor = seColor.cgColor
        anonymousNickname.layer.borderColor = seColor.cgColor
        anonymousPassword.layer.borderColor = seColor.cgColor
        tagNumTextField.layer.borderColor = seColor.cgColor
    }
    
    func setBorderWidth(borderWidth: CGFloat){
        titleField.layer.borderWidth = borderWidth
        textField.layer.borderWidth = borderWidth
        btnSubmit.layer.borderWidth = borderWidth
        btnCheckFile.layer.borderWidth = borderWidth
        anonymousNickname.layer.borderWidth = borderWidth
        anonymousPassword.layer.borderWidth = borderWidth
        tagNumTextField.layer.borderWidth = borderWidth
    }
    
    func imageTintColorSettings() {
        let box = UIImage(named: "box.svg")?.withRenderingMode(.alwaysTemplate)
        btnCheckBox.setBackgroundImage(box, for: .normal)
        
        let checkbox = UIImage(named: "checkbox.svg")?.withRenderingMode(.alwaysTemplate)
        btnCheckBox.setBackgroundImage(checkbox, for: .selected)
        
        btnCheckBox.tintColor = seColor
    }
    
    func checkLogin() {
        if UserDefaults.standard.string(forKey: "loginId") != nil {
            anonymousNickname.text = "ID : " + UserDefaults.standard.string(forKey: "loginId")!
            anonymousPassword.text = UserDefaults.standard.string(forKey: "loginPw")
            
            anonymousNickname.isUserInteractionEnabled = false
            anonymousPassword.isUserInteractionEnabled = false
            setTagList()
            isLogin = true
        } else {
            isLogin = false
        }
    }
    
    func createTagPicker() {
        let tagPicker = UIPickerView()
        tagPicker.delegate = self
        tagPicker.dataSource = self
        tagNumTextField.inputView = tagPicker
        tagPicker.selectRow(0, inComponent: 0, animated: true)
    }
    
    func createToolBar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneBtn = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(dismissKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolBar.setItems([flexibleSpace, doneBtn], animated: false)
        tagNumTextField.inputAccessoryView = toolBar
        toolBar.updateConstraintsIfNeeded()
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tagList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return tagList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tagNumTextField.text = tagList[row]
        tagId = row + 1
    }
    
    @IBAction func btnAlignLeft(_ sender: Any) {
        textField.textAlignment = NSTextAlignment.left
    }
    @IBAction func btnAlignRight(_ sender: Any) {
        textField.textAlignment = NSTextAlignment.right
    }
    @IBAction func btnAlignCenter(_ sender: Any) {
        textField.textAlignment = NSTextAlignment.center
    }
    @IBAction func btnAlignJustify(_ sender: Any) {
        textField.textAlignment = NSTextAlignment.justified
    }
    
    func setTagList (success: (()->Void)? = nil, fail: ((String)->Void)? = nil) {
        let tagUrl = "http://swagger.se-testboard.duckdns.org/api/v1/tag?direction=ASC&page=1&size=50"
        let tokenUtils = TokenUtils()
        let header = tokenUtils.getAuthorizationHeader()
        let call = AF.request(tagUrl, encoding: JSONEncoding.default, headers: header)
        
        call.responseJSON { res in
            let result = try! res.result.get()
            guard let jsonObject = result as? NSDictionary else {
                fail?("오류:\(result)")
                return
            }
            if jsonObject["status"] is Int {
                let resultCode = jsonObject["status"] as! Int
                print(resultCode)
                if resultCode == 200 {
                    let temp = jsonObject["data"] as? NSDictionary
                    //let content = temp?.value(forKey: "content") as! NSDictionary
                    if let temp2 = temp?.value(forKey: "content") as? [Any] {
                        for numbers in 0..<temp2.count {
                            let temp3 = temp2[numbers] as? [String: Any]
                            var temp: String
                            temp = (temp3?["text"] as? String)!
                            self.tagList.append(temp)
                        }
                    }
                    
                    success?()
                } else {
                    let msg = (jsonObject["message"] as? String) ?? "게시글 불러오기 실패"
                    fail?(msg)
                    print("fail")
                }
            }
        }
    }
    @IBAction func btnSubmit(_ sender: Any) {
        if checkIsValid() == true {
            let post = Post()
            let param: Parameters?
            post.anonymousNickname = anonymousNickname.text!
            post.anonymousPassword = anonymousPassword.text!
            post.title = titleField.text!
            
//            let htmlString = textField.attributedText!
//            post.text = htmlToAttributedString(myHtml: htmlString!)
//
//            post.text = textField.text!
//
            let tempText = "<p>" + textField.text! + "</p>"
            post.textString = tempText
            
            if isCheck == false {
                post.isSecret = "NORMAL"
            } else {
                post.isSecret = "SECRET"
            }
            if tagId != 0 {
                post.tagId = tagId
                
            }
            
            let url = "http://swagger.se-testboard.duckdns.org/api/v1/post"
            
            if tagId != 0 {
                param = [
                    "anonymous":  ["anonymousNickname": post.anonymousNickname!, "anonymousPassword": post.anonymousPassword!],
                    "boardId": 1,
                    "isNotice": "NORMAL",
                    "isSecret": post.isSecret!,
                    "postContent": ["text": post.textString!, "title": post.title!],
                    "tagList": [["tagId": post.tagId!]]
                ]
            } else {
                param = [
                    "anonymous":  ["anonymousNickname": post.anonymousNickname!, "anonymousPassword": post.anonymousPassword!],
                    "boardId": 1,
                    "isNotice": "NORMAL",
                    "isSecret": post.isSecret!,
                    "postContent": ["text": post.textString!, "title": post.title!]
                ]
            }
            
            let call: DataRequest
            
            if isLogin == false {
                call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default)
            } else {
                let tokenUtils = TokenUtils()
                let header = tokenUtils.getAuthorizationHeader()
                call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
            }
            call.responseJSON { res in
                let result = try! res.result.get()
                guard let jsonObject = result as? NSDictionary else {
                    return
                }
                if jsonObject["status"] is Int{
                    let resultCode = jsonObject["status"] as! Int
                    if resultCode == 201 {
                        self.dismissAlert("게시글 등록에 성공했습니다.\n새로고침 버튼을 눌러주세요.")
                    } else {
                        let msg = jsonObject["message"] as! String
                        self.alert(msg)
                    }
                }
            }
        }
    }
    
    func checkIsValid() -> Bool {
        if titleField.text!.count < 1 {
            alert("제목을 입력해 주세요.")
            return false
        } else if textField.text!.count < 1 {
            alert("내용을 입력해 주세요.")
            return false
        } else if anonymousNickname.text!.count < 1 {
            alert("닉네임을 입력해 주세요.")
            return false
        } else if anonymousPassword.text!.count < 1 {
            alert("비밀번호를 입력해 주세요.")
            return false
        } else {
            return true
        }
    }
    

}

