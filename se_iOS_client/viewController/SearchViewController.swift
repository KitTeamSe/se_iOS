//
//  SearchViewController.swift
//  se_iOS_client
//
//  Created by syon on 2021/05/19.
//

import UIKit
import Alamofire
import WebKit

/*
class SearchViewController: UIViewController, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    
    //var allLocations:[Post] = []
    //var filteredLocation:[Post] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    func setUpSearchController() {
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.placeholder = "검색어를 입력하세요."
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchController.searchBar.sizeToFit()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        <#code#>
    }

}*/

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    @IBOutlet weak var mySearchBar: UISearchBar!
    @IBOutlet weak var searchResultTableView: UITableView!
    
    var pageSize: Int = 0
    var pageNum: Int = 1
    
    var previewPost: [Post] = []
    var createAt: [String] = []

    var pageEmptyCheck: Bool?
    
    var searchText: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchResultTableView.dataSource = self
        self.searchResultTableView.delegate = self
  
        
        self.mySearchBar.delegate = self
        self.mySearchBar.placeholder = "검색어를 입력하세요."
        
        hideKeyboard()
    }
    
    func getSearch(searchText: String, success: (()->Void)? = nil, fail: ((String)->Void)? = nil) {
        //self.indicatorView.startAnimating()
        let url = "http://swagger.se-testboard.duckdns.org/api/v1/post/search"

        let param: Parameters = [
            "boardId"               : 1,
            "keyword"               : searchText,
            "pageRequest"           : ["direction" : "ASC", "page" : 1, "size" : 50],
            "postSearchType"        : "TITLE_TEXT"
        ]
        
        var call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default)
        
        if UserDefaults.standard.string(forKey: "loginId") != nil {
            let tokenUtils = TokenUtils()
            let header = tokenUtils.getAuthorizationHeader()
            
            call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
        }
        
        self.previewPost = []
        
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
                                
                                let htmlString = temp3?["previewText"] as? String
                                post.previewText = htmlToAttributedString(myHtml: htmlString!)
                                
                                post.postId = temp3?["postId"] as? Int
                                self.previewPost.append(post)
                            }
                        }
                    }
                    self.searchResultTableView.reloadData()
                    success?()
                } else {
                    let msg = (jsonObject["message"] as? String) ?? "개인정보 불러오기 실패"
                    fail?(msg)
                }
            }
            //self.indicatorView.stopAnimating()
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
        let cell: SearchTableViewCell = searchResultTableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        cell.selectionStyle = .none
        if self.pageEmptyCheck == false {
            cell.createAtLbl.text! = self.createAt[indexPath.row]
            cell.titleLbl.text! = self.previewPost[indexPath.row].title!
            cell.previewTextLbl?.attributedText! = self.previewPost[indexPath.row].previewText!
        } else {
            cell.createAtLbl.text! = ""
            cell.titleLbl.text! = "게시글이 없습니다."
            cell.previewTextLbl.text! = ""
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("안눌려 왜")
        let sendPostId = self.previewPost[indexPath.row].postId!
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "PostRead") as? PostReadViewController else {
            return
        }
        vc.receivePostId = sendPostId
        show(vc, sender: nil)
    }

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        searchText = self.mySearchBar.text
        self.mySearchBar.showsCancelButton = false
        self.mySearchBar.text = ""
        self.mySearchBar.resignFirstResponder()
        getSearch(searchText: searchText!)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.mySearchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.mySearchBar.showsCancelButton = false
        self.mySearchBar.text = ""
        self.mySearchBar.resignFirstResponder()
    }
    
}

