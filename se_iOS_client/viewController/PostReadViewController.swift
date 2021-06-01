//
//  PostReadViewController.swift
//  se_iOS_client
//
//  Created by syon on 2021/05/30.
//

import UIKit
import Alamofire

class PostReadViewController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var textField: UITextView!
    
    @IBOutlet weak var anonymousNicknameField: UILabel!
    @IBOutlet weak var createdAtField: UILabel!
    @IBOutlet weak var tagName: UILabel!
    
    var receivePostId: Int?
    
    let seColor = #colorLiteral(red: 0.3450980392, green: 0.7490196078, blue: 0.8823529412, alpha: 1)
    var radius: CGFloat!
    var borderWidth: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRadius(radius: 4)
        setBorderColor()
        setBorderWidth(borderWidth: 1.5)
        getPost()
    }
    
    func getPost(success: (()->Void)? = nil, fail: ((String)->Void)? = nil) {
        let url = "http://swagger.se-testboard.duckdns.org/api/v1/post/" + String(receivePostId!)

        let call = AF.request(url, encoding: JSONEncoding.default)
        
        call.responseJSON { res in
            let result = try! res.result.get()
            guard let jsonObject = result as? NSDictionary else {
                fail?("오류:\(result)")
                return
            }
            if jsonObject["status"] is Int {
                let resultCode = jsonObject["status"] as! Int
                if resultCode == 201 {
                    print("status 부르기 성공")
                    let temp = jsonObject["data"] as? [String: Any]
                    let myPost = Post()
                    myPost.postId = temp?["postId"] as? Int
                    myPost.boardId = temp?["boardId"] as? Int
                    myPost.boardNameEng = temp?["boardNameEng"] as? String
                    myPost.boardNameKor = temp?["boardNameKor"] as? String
                    myPost.views = temp?["views"] as? Int
                    myPost.isSecret = temp?["isSecret"] as? String
                    myPost.isNotice = temp?["isNotice"] as? String
                    myPost.anonymousNickname = temp?["anonymousNickname"] as? String
                    myPost.nickname = temp?["nickname"] as? String
                    
                    let temp2 = temp?["postContent"] as? [String: Any]
                    myPost.title = temp2?["title"] as? String
                    
                    let htmlString = temp2?["text"] as? String
                    myPost.text = htmlToAttributedString(myHtml: htmlString!)
                    
                    
                    if let tempCreateAt = temp?["createdAt"] as? [Int] {
                        
                        var yearMonthDayStringArray = tempCreateAt.map { String($0) }
                        yearMonthDayStringArray.removeLast()
                        yearMonthDayStringArray.removeLast()
                        yearMonthDayStringArray.removeLast()
                        yearMonthDayStringArray.removeLast()
                        let tempYearMonthDay = yearMonthDayStringArray.joined(separator: "-")
                        
                        if let tempCreate2 = temp?["createdAt"] as? [Int] {
                            var timeStringArray = tempCreate2.map { String($0) }
                            timeStringArray.removeLast()
                            timeStringArray.removeLast()
                            timeStringArray.removeFirst()
                            timeStringArray.removeFirst()
                            timeStringArray.removeFirst()
                            let tempTime = timeStringArray.joined(separator: ":")
                            
                            let createAt: String = tempYearMonthDay + " " + tempTime
                            myPost.createAt = createAt
                        }
                    }
                    if let tempTagList = temp?["tags"] as? [Any] {
                        myPost.tagNameList = []
                        for numbers in 0..<tempTagList.count {
                            let temp3 = tempTagList[numbers] as? [String: Any]
                            let tag = Tag()
                            tag.tagId = temp3?["tagId"] as? Int
                            tag.tagName = temp3?["tag"] as? String
                            myPost.tagNameList?.append(tag.tagName!)
                            
                        }
                    }
                    
                    self.setBinding(post: myPost)
                    success?()
                } else {
                    let msg = (jsonObject["message"] as? String) ?? "게시글 불러오기 실패"
                    fail?(msg)
                    self.alert("게시글 불러오기에 실패했습니다. 오류내용 : \(msg)")
                }
            }
        }
    }
    
    func setBinding(post: Post) {
        navigationBar.topItem?.title = post.boardNameEng
        titleField.text = post.title
        textField.attributedText = post.text
        createdAtField.text = post.createAt
        
        if post.anonymousNickname != nil {
            anonymousNicknameField.text = "작성자 : " + post.anonymousNickname!
        } else if post.nickname != nil {
            anonymousNicknameField.text = "작성자 : " + post.nickname!
        }
        
        if tagNameListToString(tagNameList: post.tagNameList!).isEmpty {
            tagName.text = "등록된 태그가 없습니다."
        } else {
            tagName.text = "등록된 태그 : " + tagNameListToString(tagNameList: post.tagNameList!)
        }
    }
    
    func tagNameListToString(tagNameList: [String]) -> String {
        if tagNameList.count == 0 {
            return ""
        } else if tagNameList.count == 1 {
            let myReturn = tagNameList.first!
            return myReturn
        } else {
            let myReturn = tagNameList.joined(separator: ", ")
            return myReturn
        }
    }
    
    func setRadius(radius: CGFloat) {
        titleField.layer.cornerRadius = radius
        textField.layer.cornerRadius = radius
    }
    
    func setBorderColor(){
        titleField.layer.borderColor = seColor.cgColor
        textField.layer.borderColor = seColor.cgColor
    }
    
    func setBorderWidth(borderWidth: CGFloat){
        titleField.layer.borderWidth = borderWidth
        textField.layer.borderWidth = borderWidth
    }
}
