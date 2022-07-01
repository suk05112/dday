//
//  IterCell.swift
//  Dday
//
//  Created by 한수진 on 2021/08/09.
//

import UIKit

class IterCell: UITableViewCell {
    
    var indexOfOneAndOnly: Int?
    var iterButtons: [UIButton] = []
    var iterButton1: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Week", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    var iterButton2: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Month", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    var iterButton3: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Year", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    private func loadView() {
        addSubview(iterButton1)
        addSubview(iterButton2)
        addSubview(iterButton3)

        iterButton1.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(50)
            make.centerY.equalTo(self.snp.centerY)
        }
        iterButton1.snp.makeConstraints { make in
            make.left.equalTo(iterButton1.snp.rightMargin)
            make.centerY.equalTo(self.snp.centerY)
        }
        iterButton1.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(50)
            make.centerY.equalTo(self.snp.centerY)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        week.setBackgroundColor(.red, for: .normal)
//        week.setBackgroundColor(.blue, for: .selected)
//        week.setBackgroundColor(.gray, for: .disabled)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        iterButtons = [iterButton1, iterButton2, iterButton3]
    }
    
    required init?(coder: NSCoder) {
       super.init(coder: coder)
   }

}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(backgroundImage, for: state)
    }
}
