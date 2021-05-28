//
//  PostTableViewCell.swift
//  se_iOS_client
//
//  Created by syon on 2021/05/25.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var previewTextLbl: UILabel!
    @IBOutlet weak var createAtLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("\n-------------------[awakeFromNib]-------------------\n")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
