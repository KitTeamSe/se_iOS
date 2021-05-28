//
//  FreeboardViewController.swift
//  se_iOS_client
//
//  Created by syon on 2021/05/19.
//

import UIKit
import Alamofire

class FreeboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    @IBOutlet weak var btnLoginLogout: UIBarButtonItem!
    @IBOutlet weak var btnUploadPost: UIBarButtonItem!
    
    @IBOutlet weak var postTableView: UITableView!
    
    var isLogin: Bool!
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var btnPreviewPage: UIButton!
    @IBOutlet weak var btnNextPage: UIButton!
    
    var pageSize: Int = 0
    var pageNum: Int = 1
    
    var previewPost: [Post] = []
    var createAt: [String] = []
    
    override func viewDidLoad() {
        //self.isLogin = appDelegate.isLogin!
        isLogin = false
        changeBtnLoginLogOut()
        
        getPost(boardId: 1, direction: "DESC", page: pageNum, size: 25)

        
       
        super.viewDidLoad()
        
        self.postTableView.dataSource = self
        self.postTableView.delegate = self
        
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
    
    
    
    func getPost(boardId: Int, direction: String, page: Int, size: Int, success: (()->Void)? = nil, fail: ((String)->Void)? = nil) {
        let url = "http://swagger.se-testboard.duckdns.org/api/v1/post?" + "boardId=" + String(boardId) + "&direction=" + direction + "&page=" + String(page) + "&size=" + String(size)
    
        let call = AF.request(url, encoding: JSONEncoding.default)
        
        call.responseJSON { res in
            let result = try! res.result.get()
            guard let jsonObject = result as? NSDictionary else {
                fail?("오류:\(result)")
                return
            }
            if jsonObject["status"] is Int {
                print("bbb")
                let resultCode = jsonObject["status"] as! Int
                print(resultCode)
                if resultCode == 201 {
                    let temp = jsonObject["data"] as? NSDictionary
                    //let content = temp?.value(forKey: "content") as! NSDictionary
                    if let temp2 = temp?.value(forKey: "content") as? [Any] {
                        self.pageSize = temp2.count
                        print("나야나ㅏ나나")
                        print(self.pageSize)
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
                            print(self.createAt[numbers])
                            let post = Post()
                            post.title = temp3?["title"] as? String
                            post.previewText = temp3?["previewText"] as? String
                            post.postId = temp3?["postId"] as? Int
                            self.previewPost.append(post)
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
        if self.createAt.count > 0 {
            cell.createAtLbl.text! = self.createAt[indexPath.row]
            cell.titleLbl.text! = self.previewPost[indexPath.row].title!
            cell.previewTextLbl.text! = self.previewPost[indexPath.row].previewText!
        }
        return cell
    }
 
}
