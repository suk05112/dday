//
//  TableViewCell.swift
//  Dday
//
//  Created by 한수진 on 2022/06/26.
//

import Foundation
import UIKit
import SnapKit

class TableViewCell: UITableViewCell {
    
    var cellSwitch: UISwitch = {
        let cellSwitch = UISwitch()
        cellSwitch.translatesAutoresizingMaskIntoConstraints = false
        return cellSwitch
    }()
    
    private func loadView() {
        super.contentView.addSubview(cellSwitch)
        
        cellSwitch.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(50)
            make.centerY.equalTo(self.snp.centerY)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadView()
    }

    required init?(coder: NSCoder) {
       super.init(coder: coder)
   }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        print("selected", selected)
        // Configure the view for the selected state
    }

}
