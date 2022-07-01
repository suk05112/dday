//
//  HeaderCell.swift
//  Dday
//
//  Created by 한수진 on 2021/08/08.
//

import UIKit

class HeaderCell: UITableViewHeaderFooterView {

    var cellSwitch: UISwitch = {
        let cellSwitch = UISwitch()
        cellSwitch.translatesAutoresizingMaskIntoConstraints = false

        return cellSwitch
    }()
    
    private func loadView() {
        super.contentView.addSubview(cellSwitch)
        cellSwitch.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 00, left: 00, bottom: 0, right: 50))

//            make.right.equalToSuperview().offset(100)
//            make.right.equalTo(self.view.snp.rightMargin)
            make.centerY.equalTo(self.snp.centerY)
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        loadView()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init?(coder: NSCoder) {
       super.init(coder: coder)
   }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
