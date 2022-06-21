//
//  Add.swift
//  Dday
//
//  Created by 한수진 on 2021/07/22.
//

import UIKit
import WidgetKit

class AddViewController: UIViewController {
    
    let mode = "init"
    @IBOutlet var showPickerTime: UILabel!
    @IBOutlet weak var inputname: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!

    let headerCellIdentifier = "headerCell"
    let iterIdentifier = "Itercell"
    let alarmIdentifier = "AlarmCell"
    
    var indexOfOneAndOnly: Int?
    var indexOfAlarm: Int?

    var iterBtnPressed: [Bool] = [false, false, false] // week, month, year 버튼
    var alarmBtnPressed: [Bool] = [false, false, false]
    var isPressed: [Bool] = [false, false, false] // 각 스위치 버튼 눌려있는지

//    let setting:[String] = ["  반복", "  설정일을 1일부터 시작", "  위젯"] //tableview 안내문구
    let setting: [String] = ["Iter".localized(), "set1".localized(), "widget".localized()] // tableview 안내문구

    var setValue = Setting(iter: .none, set1: false, widget: false) // 최종적으로 저장할 데이터

    var delegate: SendProtocol?

    var selectDate =  Date()
    let dele =  UIApplication.shared.delegate as? AppDelegate

    let dateFormatter = DdayDateFormatter.shared
    let notification = DdayNotificationCenter()

    let didDismissPostCommentViewController: Notification.Name = Notification.Name("DidDismissPostCommentViewController")

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))

        inputname.placeholder = "title".localized()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = false
        
        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableView.automaticDimension
        
        loadData()
        
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            view.endEditing(true) // todo...
        }
        sender.cancelsTouchesInView = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         self.view.endEditing(true)
   }
    
    func loadData() {
        let item = Item()
 
        if dele!.mode == "UPDATE" {
            let idx = (dele?.updateIdx)!
            let (name, day, _) = item.getItemData(idx: idx)
            let setting = item.getItemSetting(idx: idx)
            indexOfOneAndOnly = setting.iter.rawValue - 1
            print("update mode")
            print(day.components(separatedBy: " ")[0])
            
            inputname.text = name
            datePicker.date = dateFormatter.date(from: day)!
            selectDate = dateFormatter.date(from: dateFormatter.string(from: datePicker.date))!
            
            isPressed = [setting.iter != .none ? true : false, setting.set1, setting.widget]
            setValue = setting
            iterBtnPressed = setting.iter.pressedBtn()

/*
            if (setting.iter == .none){
                isPressed = [false, setting.set1, setting.widget]
                setValue = Setting(iter: .none, set1: isPressed[1], widget: isPressed[2])

            }else{
                isPressed = [true, setting.set1, setting.widget]
                iterBtnPressed = setting.iter.pressedBtn()
                setValue = Setting(iter: setting.iter, set1: isPressed[1], widget: isPressed[2])

            }
 */

        }
    }
    
    @IBAction func textDidChanged(_ sender: Any) {
        checkMaxLength(textField: inputname, maxLength: 10)
    }
    
    @IBAction func changeDatePIcker(_ sender: UIDatePicker) {
        let datePickerView = sender
        selectDate = dateFormatter.date(from: dateFormatter.string(from: datePickerView.date))!
    }
    
    @IBAction func saveDday(_ sender: UIButton) {

        if inputname.text == "" {
            inputname.text = "이름 없음"
        }
        
        if isPressed[0]==false {
            setValue.iter = .none
        }
        
        if dele!.mode == "UPDATE" {
            updateDday()
        } else {
            delegate?.send(date: selectDate, name: inputname.text!, setting: setValue, idx: CoreDataManager.shared.getCount())
        }

        NotificationCenter.default.post(name: didDismissPostCommentViewController, object: nil, userInfo: nil)
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func updateDday() {
        let calculatedDday = CalculateDay.shared.calculateDday(selectDay: selectDate, setting: setValue) // dday
        
        let data = RecieveData(name: inputname.text!,
                           day: dateFormatter.string(from: selectDate),
                           dday: calculatedDday)
        
        Item().update(data: data, setting: setValue, idx: dele!.updateIdx)

        notification.removeNotification(idx: dele!.updateIdx)
        notification.setNoticifation(idx: dele!.updateIdx)
        
    }
    
    // option + cmd + 화살표
    @objc func switchChanged(_ sender: UISwitch!) {
    
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        
        switch sender.tag {
        case 0:
            if !sender.isOn {
                setValue.iter = .none
//                iterBtnPressed = [false, false, false]
            }
        case 1:
            sender.isOn ? (setValue.set1 = true) : (setValue.set1 = false)
        case 2:
            sender.isOn ? (setValue.widget = true) : (setValue.widget = false)
        default:
            setValue = Setting(iter: .none, set1: false, widget: false)
        }
        
        print( "변경된 switch", sender.tag)
        isPressed[sender.tag].toggle()
        tableView.reloadData()
    }
    
    @objc func iterBtnClicked(_ sender: UIButton) {
        print("sender: ", sender.tag, sender.isSelected)

        if (indexOfOneAndOnly != nil) && indexOfOneAndOnly != -1 { // 하나라도 선택되어있을 때
            if !iterBtnPressed[sender.tag] { // 다른게 눌려져있으면
                for index in iterBtnPressed.indices { // 전부다 false로 만들고
                    iterBtnPressed[index] = false
                }
                
                iterBtnPressed[sender.tag] = true
                indexOfOneAndOnly = sender.tag
                setValue.iter = Iter(rawValue: sender.tag + 1)!

            } else { // 누른게 자기자신이라면
                iterBtnPressed[sender.tag] = false
                indexOfOneAndOnly = nil
                setValue.iter = Iter.none
            }

        } else { // 하나도 선택되어있지 않을 때
            iterBtnPressed[sender.tag] = true
            indexOfOneAndOnly = sender.tag
            setValue.iter = Iter(rawValue: sender.tag + 1)!

        }
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }

}

extension AddViewController: UITextFieldDelegate {

    func checkMaxLength(textField: UITextField!, maxLength: Int) {
        inputname.delegate = self

        if (textField.text?.count)! > 10 {
            textField.deleteBackward()
        }
    }

}

extension String {
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
}
protocol SendProtocol {
    func send(date: Date, name: String, setting: Setting, idx: Int)
}
