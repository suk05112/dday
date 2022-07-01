//
//  ItemCell.swift
//  Dday
//
//  Created by 한수진 on 2022/06/20.
//

import Foundation
import UIKit

//extension ViewController: UICollectionViewDelegateFlowLayout {
extension ViewController {

    // 지정된 섹션에 표시할 항목의 개수를 묻는 메서드
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { // 2
//        return self.numberOfCell
        return getfilterdIndexByset1().count
    }

    // 컬렉션뷰의 지정된 위치에 표시할 셀을 요청하는 메서드
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? Data else {
//            return UICollectionViewCell()
//        }

        guard let cell: CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CollectionViewCell else { return CollectionViewCell() }
        let index: Int = getfilterdIndexByset1()[indexPath.row]
        let (_, day, dday) = item.getItemData(idx: index)
        let setting = item.getItemSetting(idx: index)

        cell.day.text = day
        cell.name.text = CoreDataManager.shared.getEntity(key: "name", idx: index)
        cell.dday.textAlignment = .left
        cell.dday.text = item.getDdayString(dday: Int(dday)!, set1: setting.set1)

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
        let detail = DetailViewController()
        
        if let cell : CollectionViewCell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CollectionViewCell{
            let (name, day, dday) = item.getItemData(idx: indexPath.row)

            detail.idx = indexPath.row
            detail.data = RecieveData(name: name, day: day, dday: Int(dday)!)
//                detail.idx = getfilterdIndexByset1()[indexPath.row]

        }
        detail.modalPresentationStyle = .formSheet
        self.present(detail, animated: true, completion: nil)
        }

    func setCeelColor(idx: Int, cell: UIView) {
        let colors = ["level1", "level2", "level3", "level4"]
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
    
    func getfilterdIndexByset1() -> [Int] {
        
        let numOfdata = CoreDataManager.shared.getCount()
        var filteredIdx: [Int] = []
        
        if UserDefaults.standard.bool(forKey: "hide") {
            for idx in 0..<numOfdata {
                if CoreDataManager.shared.getSetting(idx: idx).set1 ||
                    Int(CoreDataManager.shared.getEntity(key: "dday", idx: idx))! < 1 {
                    filteredIdx.append(idx)
                }
            }
        } else {
            filteredIdx = Array(0..<numOfdata)
        }

        return filteredIdx
    }
}


