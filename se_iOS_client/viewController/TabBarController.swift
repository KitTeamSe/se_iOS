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
    
    

    override func viewDidLoad() {
        
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
    
    
    
    
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    

}

