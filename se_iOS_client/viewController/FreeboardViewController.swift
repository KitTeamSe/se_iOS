//
//  FreeboardViewController.swift
//  se_iOS_client
//
//  Created by syon on 2021/05/19.
//

import UIKit
import Alamofire

protocol SendDataDelegate {
    func sendData(data: Bool)
}

class FreeboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    @IBOutlet weak var btnLoginLogout: UIBarButtonItem!

    @IBOutlet weak var btnUploadPost: UIButton!
    
    @IBOutlet weak var postTableView: UITableView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var isLogin: Bool!
    
    @IBOutlet weak var btnPreviewPage: UIButton!
    @IBOutlet weak var btnNextPage: UIButton!
    
    var pageSize: Int = 0
    var pageNum: Int = 1
    
    var previewPost: [Post] = []
    var createAt: [String] = []
    
    var pageEmptyCheck: Bool?
    
    override func viewDidLoad() {
        //self.isLogin = appDelegate.isLogin!
        isLogin = false
        changeBtnLoginLogOut()
        getPost(boardId: 1, direction: "DESC", page: pageNum, size: 25)
        
        super.viewDidLoad()
        self.postTableView.dataSource = self
        self.postTableView.delegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.postTableView.reloadData()
    }

    @IBAction func btnLoginLogout(_ sender: Any) {
        if isLogin == false {
            self.dismiss(animated: true)
        } else {
            isLogin = false
            changeBtnLoginLogOut()
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
    
    @IBAction func btnNextpage(_ sender: Any) {
        self.btnPreviewPage.isUserInteractionEnabled = true
        if self.pageEmptyCheck == false {
            pageNum = pageNum + 1
            getPost(boardId: 1, direction: "DESC", page: pageNum, size: 25)
        } else {
            alert("마지막 페이지입니다.")
            pageNum = pageNum - 1
            self.btnNextPage.isUserInteractionEnabled = false
        }
        
    }
    @IBAction func btnPreviewPage(_ sender: Any) {
        self.btnNextPage.isUserInteractionEnabled = true
        if pageNum == 1 {
            print(pageNum)
            self.btnPreviewPage.isUserInteractionEnabled = false
        } else {
            pageNum = pageNum - 1
            getPost(boardId: 1, direction: "DESC", page: pageNum, size: 25)
            print(pageNum)
        }
    }
    @IBAction func btnAction(_ sender: Any) {
        getPost(boardId: 1, direction: "DESC", page: pageNum, size: 25)
    }
    
    
    func getPost(boardId: Int, direction: String, page: Int, size: Int, success: (()->Void)? = nil, fail: ((String)->Void)? = nil) {
        self.indicatorView.startAnimating()
        let url = "http://swagger.se-testboard.duckdns.org/api/v1/post?" + "boardId=" + String(boardId) + "&direction=" + direction + "&page=" + String(page) + "&size=" + String(size)
    
        let call = AF.request(url, encoding: JSONEncoding.default)
        self.previewPost = []
        
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
                    let temp = jsonObject["data"] as? NSDictionary
                    if let tempPostListItem = temp?.value(forKey: "postListItem") as? [String: Any] {
                        
                        if let tempCheck = tempPostListItem["empty"] as? Bool {
                            self.pageEmptyCheck = tempCheck
                        }
                        
                        if let temp2 = tempPostListItem["content"] as? [Any] {
                            
                            self.pageSize = temp2.count
                            for numbers in 0..<temp2.count {
                                let temp3 = temp2[numbers] as? [String: Any]
                                
                                
                                let temp4: [Int] = temp3?["createAt"] as! [Int]
                                var stringArray = temp4.map { String($0) }
                                stringArray.removeLast()
                                stringArray.removeLast()
                                stringArray.removeLast()
                                stringArray.removeLast()
                                let tempCreateAt = stringArray.joined(separator: "-")
                                
                                self.createAt.append(tempCreateAt)
                                let post = Post()
                                post.title = temp3?["title"] as? String
                                post.previewText = temp3?["previewText"] as? String
                                post.postId = temp3?["postId"] as? Int
                                self.previewPost.append(post)
                            }
                        }
                    }
                    self.postTableView.reloadData()
                    success?()
                } else {
                    let msg = (jsonObject["message"] as? String) ?? "게시글 불러오기 실패"
                    fail?(msg)
                }
            }
        }
        self.indicatorView.stopAnimating()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.pageSize > 0 {
            return self.pageSize
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PostTableViewCell = postTableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        //if self.createAt.count > 0 {
        if self.pageEmptyCheck == false {
            cell.createAtLbl.text! = self.createAt[indexPath.row]
            cell.titleLbl.text! = self.previewPost[indexPath.row].title!
            cell.previewTextLbl.text! = self.previewPost[indexPath.row].previewText!
        } else {
            cell.createAtLbl.text! = ""
            cell.titleLbl.text! = "게시글이 없습니다."
            cell.previewTextLbl.text! = ""
        }
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        <#code#>
//    }
    
}
