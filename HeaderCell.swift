//
//  HeaderCell.swift
//  Dday
//
//  Created by 한수진 on 2021/08/08.
//

import UIKit

class HeaderCell: UITableViewCell {

    @IBOutlet weak var cellSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
