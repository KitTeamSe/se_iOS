//
//  SearchTableViewCell.swift
//  se_iOS_client
//
//  Created by syon on 2021/05/20.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var previewTextLbl: UILabel!
    @IBOutlet weak var createAtLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
