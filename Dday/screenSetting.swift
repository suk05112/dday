//
//  screenSetting.swift
//  Dday
//
//  Created by 한수진 on 2021/09/20.
//

import UIKit

class screenSetting: UIViewController{
    
    
    @IBOutlet weak var tableView: UITableView!
    let headerCellIdentifier = "headerCell"
    let cellInfo:[String] = ["지난 디데이 숨기기", "dday 정렬", "dday 전날 notification"] //tableview 안내문구

    let DidDismissPostCommentViewController: Notification.Name = Notification.Name("DidDismissPostCommentViewController")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("disappear")
        NotificationCenter.default.post(name: DidDismissPostCommentViewController, object: nil, userInfo: nil)

    }
    
    @objc func switchChanged(_ sender : UISwitch!){
    
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        
        switch sender.tag{
            case 0:
                print("hide")
                if (sender.isOn) {
                    UserDefaults.standard.setValue(true, forKey: "hide")
                }else{
                    UserDefaults.standard.setValue(false, forKey: "hide")
                }

            case 1:
                if (sender.isOn) {
                    UserDefaults.standard.setValue(true, forKey: "sort")
                }else{
                    UserDefaults.standard.setValue(false, forKey: "sort")
                }
            case 2:
                if (sender.isOn) {
                    UserDefaults.standard.setValue(true, forKey: "noti")
                }else{
                    UserDefaults.standard.setValue(false, forKey: "noti")
                }
            default:
                print("default")

        }
        
        tableView.reloadData()
    }
}
    
extension screenSetting:  UITableViewDelegate, UITableViewDataSource{
    //table에 몇개의 section이 있을건지 알려줌
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //section별 몇개의 셀 있을 지
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "화면설정"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "screenCell", for: indexPath) as! screenCell
        
        cell.textLabel!.text = cellInfo[indexPath.row]
        cell.cellSwitch!.tag = indexPath.row
        cell.cellSwitch.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        
        switch cell.cellSwitch.tag{
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
