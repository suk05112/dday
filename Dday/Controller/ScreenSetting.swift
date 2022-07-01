//
//  screenSetting.swift
//  Dday
//
//  Created by 한수진 on 2021/09/20.
//

import UIKit
import SnapKit

class ScreenSetting: UIViewController {
    
    let category: UILabel = {
        let label = UILabel()
        label.text = "setting"
        label.font = UIFont.systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let headerCellIdentifier = "headerCell"
    let cellInfo: [String] = ["hide".localized(), "sort".localized(), "noti".localized()] // tableview 안내문구

    let didDismissPostCommentViewController: Notification.Name = Notification.Name("DidDismissPostCommentViewController")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableViewSetting()
        
        view.addSubview(category)
        category.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalTo(view.snp.centerX)
        }
    }
    
    func tableViewSetting() {
        tableView = UITableView(frame: self.view.bounds, style: .plain)

        self.tableView.register(TableViewCell.self, forCellReuseIdentifier: "screenCell")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(self.tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0))
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("disappear")
        NotificationCenter.default.post(name: didDismissPostCommentViewController, object: nil, userInfo: nil)
    }
    
    @objc func switchChanged(_ sender: UISwitch!) {
    
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        
        switch sender.tag {
        case 0:
            print("hide")
            if sender.isOn {
                UserDefaults.standard.setValue(true, forKey: "hide")
            } else {
                UserDefaults.standard.setValue(false, forKey: "hide")
            }
        case 1:
            if sender.isOn {
                UserDefaults.standard.setValue(true, forKey: "sort")
            } else {
                UserDefaults.standard.setValue(false, forKey: "sort")
            }
        case 2:
            if sender.isOn {
                UserDefaults.standard.setValue(true, forKey: "noti")
            } else {
                UserDefaults.standard.setValue(false, forKey: "noti")
            }
        default:
            print("default")

        }
        tableView.reloadData()
    }
}
    
extension ScreenSetting: UITableViewDelegate, UITableViewDataSource {

    // table에 몇개의 section이 있을건지 알려줌
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // section별 몇개의 셀 있을 지
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "screenSetting".localized()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "screenCell", for: indexPath) as! TableViewCell
        
        cell.selectionStyle = .none
        cell.textLabel!.text = cellInfo[indexPath.row]
        cell.cellSwitch.tag = indexPath.row
        cell.cellSwitch.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        
        switch cell.cellSwitch.tag {
        case 0:
            cell.cellSwitch.setOn(UserDefaults.standard.bool(forKey: "hide"), animated: false)
        case 1:
            cell.cellSwitch.setOn(UserDefaults.standard.bool(forKey: "sort"), animated: false)
        case 2:
            cell.cellSwitch.setOn(UserDefaults.standard.bool(forKey: "noti"), animated: false)
        default:
            cell.cellSwitch.setOn(false, animated: false)
        }
        
        return cell
    }
    
}
