//
//  TagTableViewCell.swift
//  se_iOS_client
//
//  Created by syon on 2021/05/30.
//

import UIKit

class TagTableViewCell: UITableViewCell {

    @IBOutlet weak var tagIdField: UILabel!
    @IBOutlet weak var tagNameField: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("\n-------------------[awakeFromNib]-------------------\n")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
