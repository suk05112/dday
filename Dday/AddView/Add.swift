//
//  Add.swift
//  Dday
//
//  Created by 한수진 on 2022/06/21.
//

import Foundation
import UIKit

extension AddViewController: UITableViewDelegate, UITableViewDataSource {
    
    // table에 몇개의 section이 있을건지 알려줌
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    // section별로 몇개의 row가 있어야하는지
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return isPressed[section] ? 1:0
        } else {return 0}
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.headerCellIdentifier) as! HeaderCell
        let text = setting[section]
        
        print(section)
        cell.textLabel?.text = text
        cell.cellSwitch.tag = section // for detect which row switch Changed
        cell.cellSwitch.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        
        cell.cellSwitch.setOn(isPressed[section], animated: true)
        
        return cell
    }

    // 헤더 셀의 높이
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    // footer 없애기
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        tableView.sectionFooterHeight = .leastNonzeroMagnitude

        return CGFloat.leastNonzeroMagnitude
    }
    
    // tableview에 넣을 cell을 직접적으로 요청하는 함수
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: self.iterIdentifier, for: indexPath) as! IterCell
        cell.selectionStyle = .none
        
        for idx in 0...2 {
            cell.iterButtons[idx].tag = idx
            cell.iterButtons[idx].addTarget(self, action: #selector(self.iterBtnClicked(_:)), for: .touchUpInside)
            cell.iterButtons[idx].isSelected = iterBtnPressed[idx]
        }
        print("버튼 값", iterBtnPressed)

        return cell
        
    }
    
}
