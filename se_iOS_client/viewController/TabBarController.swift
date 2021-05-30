//
//  TabBarController.swift
//  se_iOS_client
//
//  Created by syon on 2021/05/03.
//

import UIKit


class TabBarController: UITabBarController {

    

    lazy var seColor = hexStringToUIColor(hex: "#58BFE1")
    lazy var nonClickColor = hexStringToUIColor(hex: "#E2E2E2")
    
    //var isLogin: Bool!
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        
        //appDelegate.isLogin = self.isLogin
        
        
        self.selectedIndex = 2;

        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [.foregroundColor: seColor]
            appearance.largeTitleTextAttributes = [.foregroundColor: seColor]

            UINavigationBar.appearance().tintColor = seColor
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().tintColor = seColor
            UINavigationBar.appearance().barTintColor = .white
            UINavigationBar.appearance().isTranslucent = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    

}

