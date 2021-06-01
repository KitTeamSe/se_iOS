//
//  MenuViewController.swift
//  se_iOS_client
//
//  Created by syon on 2021/06/01.
//

import UIKit
import Alamofire

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var menuTableView: UITableView!
    
    var menuList: [Menu] = []
    var pageSize: Int = 0
    var pageEmptyCheck: Bool?
    
    override func viewDidLoad() {
        
        getMenuList()
        self.menuTableView.dataSource = self
        self.menuTableView.delegate = self
        super.viewDidLoad()
        
        if UserDefaults.standard.string(forKey: "loginId") == nil {
            getMenuList()
        } else {
            getAllMenuList()
        }
    }
    
    func getMenuList() {
        let url = "http://swagger.se-testboard.duckdns.org/api/v1/menu"
        let call = AF.request(url, encoding: JSONEncoding.default)
        
        call.responseJSON { res in
            let result = try! res.result.get()
            guard let jsonObject = result as? NSDictionary else {
                self.pageEmptyCheck = true
                return
            }
            if jsonObject["status"] is Int {
                let resultCode = jsonObject["status"] as! Int
                if resultCode == 201 {
                    self.pageEmptyCheck = false
                    if let temp = jsonObject["data"] as? [Any] {
                        self.pageSize = temp.count
                        for numbers in 0..<temp.count {
                            let tempMenu = temp[numbers] as? [String: Any]
                            let menu = Menu()
                            menu.menuId = tempMenu?["menuId"] as? Int
                            menu.nameEng = tempMenu?["nameEng"] as? String
                            self.menuList.append(menu)
                        }
                        self.menuTableView.reloadData()
                    }
                }
            }
        }
    }
    
    func getAllMenuList() {
        let url = "http://swagger.se-testboard.duckdns.org/api/v1/menu"
        let tokenUtils = TokenUtils()
        let header = tokenUtils.getAuthorizationHeader()
        let call = AF.request(url, encoding: JSONEncoding.default, headers: header)
        
        call.responseJSON { res in
            let result = try! res.result.get()
            guard let jsonObject = result as? NSDictionary else {
                self.pageEmptyCheck = true
                return
            }
            if jsonObject["status"] is Int {
                let resultCode = jsonObject["status"] as! Int
                if resultCode == 201 {
                    self.pageEmptyCheck = false
                    if let temp = jsonObject["data"] as? [Any] {
                        self.pageSize = temp.count
                        for numbers in 0..<temp.count {
                            let tempMenu = temp[numbers] as? [String: Any]
                            let menu = Menu()
                            menu.menuId = tempMenu?["menuId"] as? Int
                            menu.nameEng = tempMenu?["nameEng"] as? String
                            self.menuList.append(menu)
                        }
                        self.menuTableView.reloadData()
                    }
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
        let cell: MenuTableViewCell = menuTableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuTableViewCell
        if self.pageEmptyCheck == false {
            cell.selectionStyle = .none
            cell.menuLabel.text! = self.menuList[indexPath.row].nameEng!
        } else {
            cell.menuLabel.text! = "메뉴가 없습니다."
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tabBarController?.selectedIndex = 2
    }
}
