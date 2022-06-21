//
//  ItemCell.swift
//  Dday
//
//  Created by 한수진 on 2022/06/20.
//

import Foundation
import UIKit

class Data: UICollectionViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var dday: UILabel!
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout{
    
    //지정된 섹션에 표시할 항목의 개수를 묻는 메서드
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { //2
//        return self.numberOfCell
        return getfilterdIndexByset1().count
    }
    
    //컬렉션뷰의 지정된 위치에 표시할 셀을 요청하는 메서드
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? Data else {
            return UICollectionViewCell()
        }

        let index:Int = getfilterdIndexByset1()[indexPath.row]
        
        
        let cellDday = CoreDataManager.shared.getEntity(key: "dday", idx: index)
        let setting = CoreDataManager.shared.getSetting(idx: index)
        var targetDay: Date
        targetDay = CalculateDay.shared.getTargetDay(dday: Int(cellDday)!, set1: setting.set1)
        
        cell.day.text = dateFormatter.string(from:targetDay)
        cell.name.text = CoreDataManager.shared.getEntity(key: "name", idx: index)
        cell.dday.textAlignment = .left
        
        
        
        if(setting.set1 && setting.iter == .none){
            if (Int(cellDday)!<0){
                cell.dday.text =  "D-" + String(abs(Int(cellDday)!))
            }
            else{
                cell.dday.text = cellDday + "일"
            }

        }else{
            if (Int(cellDday)!<0){
                cell.dday.text = "D" + String(cellDday)
            }
            else if(Int(cellDday) == 0){
                cell.dday.text = "D-day"
            }
            else{
                cell.dday.text = "D+" + String(cellDday)
            }
        }

        
        setCeelColor(idx: indexPath.row, cell: cell)
        setViewShadow(backView: cell)

        cell.contentView.isUserInteractionEnabled = true

        print("setting value")
        print(CoreDataManager.shared.getEntity(key: "name", idx: index))
        print(CoreDataManager.shared.getSetting(idx: index).widget, "\n")

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 350, height: 80)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           
        }
    
    func setCeelColor(idx: Int, cell: UIView){
        let colors = ["level1", "level2", "level3","level4"]
        cell.backgroundColor = UIColor(named: colors[idx%4])
    }
    
    func setViewShadow(backView: UIView) {
        backView.layer.masksToBounds = true
        backView.layer.cornerRadius = 10
        
        backView.layer.masksToBounds = false
        backView.layer.shadowOpacity = 0.3
        backView.layer.shadowOffset = CGSize(width: -2, height: 2)
        backView.layer.shadowRadius = 3
    }
    
    func getfilterdIndexByset1() -> [Int]{
        
        let numOfdata = CoreDataManager.shared.getCount()
        var filteredIdx:[Int] = []
        
        if(UserDefaults.standard.bool(forKey: "hide")){
            for idx in 0..<numOfdata{
                if(CoreDataManager.shared.getSetting(idx: idx).set1 ||
                    Int(CoreDataManager.shared.getEntity(key: "dday", idx: idx))! < 1){
                    
                    filteredIdx.append(idx)
                }
            
            }
        }
        else{
            filteredIdx = Array(0..<numOfdata)
        }

//        print("in main view")
//        print(filteredIdx)
        return filteredIdx
    }
    
}
