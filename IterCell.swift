//
//  IterCell.swift
//  Dday
//
//  Created by 한수진 on 2021/08/09.
//

import UIKit

class IterCell: UITableViewCell {

    @IBOutlet var iterButtons: [UIButton]!
    
    var indexOfOneAndOnly: Int?

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
//        week.setBackgroundColor(.red, for: .normal)
//        week.setBackgroundColor(.blue, for: .selected)
//        week.setBackgroundColor(.gray, for: .disabled)
        
    }
    
    @IBAction func touchButton(_ sender: UIButton){
        print("btn touch")
        if indexOfOneAndOnly != nil{
            if !sender.isSelected{
                for index in iterButtons.indices{
                    iterButtons[index].isSelected = false
                }
                sender.isSelected = true
                indexOfOneAndOnly = iterButtons.firstIndex(of: sender)
            }else{
                sender.isSelected = false
                indexOfOneAndOnly = nil
            }
        
        }else{
            sender.isSelected = true
            indexOfOneAndOnly = iterButtons.firstIndex(of: sender)
        }
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
