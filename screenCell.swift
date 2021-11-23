//
//  screenCell.swift
//  Dday
//
//  Created by 한수진 on 2021/09/24.
//

//
//  screenUDcell.swift
//  Dday
//
//  Created by 한수진 on 2021/09/23.
//

import Foundation
import UIKit

class screenCell: UITableViewCell {
    
    @IBOutlet weak var cellSwitch: UISwitch!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
