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
    
    let inputname: UITextField = {
        let textfiled = UITextField()
        textfiled.translatesAutoresizingMaskIntoConstraints = false
        textfiled.placeholder = "title".localized()
        textfiled.keyboardType = .emailAddress
        textfiled.borderStyle = UITextField.BorderStyle.roundedRect
        textfiled.autocapitalizationType = .none
        return textfiled
    }()
    
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
    
        return datePicker
    }()
    
    lazy var tableView: UITableView = {
//        let tableView = UITableView()
        let tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = self
        tableView.delegate = self

        tableView.alwaysBounceVertical = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50.0
        
        tableView.register(IterCell.self, forCellReuseIdentifier: iterIdentifier)
        tableView.register(HeaderCell.self, forHeaderFooterViewReuseIdentifier: headerCellIdentifier)

        return tableView
    }()
    
    let saveButton: UIButton = {
        let saveButton = UIButton()
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("save", for: .normal)
        saveButton.setTitleColor(.black, for: .normal)
        
        return saveButton
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(inputname)
        view.addSubview(datePicker)
        view.addSubview(tableView)
        view.addSubview(saveButton)

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        inputname.delegate = self

        settingView()
        loadData()
    }

    func settingView() {
        inputname.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 30, left: 10, bottom: 10, right: 10))
//            make.top.equalTo(view.snp.topMargin)
//            make.centerX.equalTo(view.snp.centerX)
        }
        datePicker.snp.makeConstraints { make in
            make.edges.equalTo(inputname).inset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
//            make.centerX.equalTo(view.snp.centerX)
//            make.top.equalTo(inputname.snp.bottom)
        }
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 500, left: 20, bottom: 50, right: 20))
//            make.center.equalTo(view.snp.center)
//            make.top.equalTo(datePicker.snp.bottom)
        }
        saveButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(tableView.snp.bottom)
        }

        inputname.addTarget(self, action: #selector(textDidChanged), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(changeDatePIcker), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveDday), for: .touchUpInside)
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
    
    @objc func textDidChanged(_ sender: Any) {
        checkMaxLength(textField: inputname, maxLength: 10)
    }
    
    @objc func changeDatePIcker(_ sender: UIDatePicker) {
        let datePickerView = sender
        selectDate = dateFormatter.date(from: dateFormatter.string(from: datePickerView.date))!
    }
    
    @objc func saveDday(_ sender: UIButton) {
        print("save")

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

class AddView: UIView {
    
    let showPickerTime: UILabel = {
        let label = UILabel()
        label.text = "showPickerTime"
        label.font = UIFont.systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    let inputname: UITextField = {
        let textfiled = UITextField()
        textfiled.translatesAutoresizingMaskIntoConstraints = false
        textfiled.placeholder = "title".localized()
        textfiled.keyboardType = .emailAddress

        textfiled.borderStyle = UITextField.BorderStyle.roundedRect
        textfiled.autocapitalizationType = .none
        return textfiled
    }()
    
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
    
        return datePicker
    }()

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    let saveButton: UIButton = {
        let saveButton = UIButton()
        saveButton.translatesAutoresizingMaskIntoConstraints = false
//        saveButton.setTitle("save", for: .normal)
        saveButton.setTitleColor(.black, for: .normal)
        
        return saveButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadView()
    }
    
    required init?(coder: NSCoder) {
       super.init(coder: coder)
//       loadView()
   }

    private func loadView() {

//        addSubview(showPickerTime)
        addSubview(inputname)
        addSubview(datePicker)
        addSubview(tableView)
        addSubview(saveButton)

        inputname.snp.makeConstraints { make in
            make.top.equalTo(self.snp.topMargin)
            make.centerX.equalTo(self.snp.centerX)
        }
        datePicker.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(inputname.snp.bottom)
        }
        tableView.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(datePicker.snp.bottom)
        }
        saveButton.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(tableView.snp.bottom)
        }
    }
    
    private func makeView() -> UIView {
        let view = UIView()
        view.backgroundColor = .purple
        return view
    }
    
    private func makeLabel(str: String) -> UILabel {
        let label = UILabel()
        label.text = str
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }

}
