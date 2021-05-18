//
//  FreeboardViewController.swift
//  se_iOS_client
//
//  Created by syon on 2021/05/19.
//

import UIKit

class FreeboardViewController: UIViewController {

    @IBOutlet weak var postTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func btnPrevious(_ sender: Any) {
        self.dismiss(animated: true)
    }

}
