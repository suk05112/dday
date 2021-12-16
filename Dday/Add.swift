//
//  Add.swift
//  Dday
//
//  Created by 한수진 on 2021/07/22.
//

import UIKit

class Add: UIViewController {

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

    var iterBtnPressed:[Bool] = [false, false, false] //week, month, year 버튼
    var alarmBtnPressed:[Bool] = [false, false, false]
    var isPressed:[Bool] = [false, false, false] //각 스위치 버튼 눌려있는지

    let setting:[String] = ["  반복", "  설정일을 1일부터 시작", "  위젯"] //tableview 안내문구
    var setValue = Setting(iter: .none, set1: false, widget: false) //최종적으로 저장할 데이터

    var delegate : SendProtocol?
    var updateDelegate : SendUpdateProtocol?
    var selectDate =  Date()
    let dele =  UIApplication.shared.delegate as? AppDelegate
    
    let formatter = DdayDateFormmater()

    
    let DidDismissPostCommentViewController: Notification.Name = Notification.Name("DidDismissPostCommentViewController")

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = false
        
        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableView.automaticDimension
        
        showPickerTime.text = formatter.toString(date: selectDate)

        loadData()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){

         self.view.endEditing(true)

   }
    func loadData(){
        
        if(dele!.mode == "UPDATE"){
            let idx = (dele?.updateIdx)!
            indexOfOneAndOnly = CoreDataManager.shared.getSetting(idx: idx).iter.rawValue - 1
            print("update mode")
            print(CoreDataManager.shared.getEntity(key: "day", idx: idx).components(separatedBy: " ")[0])
            inputname.text = CoreDataManager.shared.getEntity(key: "name", idx: idx)
            datePicker.date = formatter.toDate(str: CoreDataManager.shared.getEntity(key: "day", idx: idx))
            
            showPickerTime.text = CoreDataManager.shared.getEntity(key: "day", idx: idx)
            
            if (CoreDataManager.shared.getSetting(idx: idx).iter == .none){
                isPressed = [false,
                             CoreDataManager.shared.getSetting(idx: idx).set1,
                             CoreDataManager.shared.getSetting(idx: idx).widget]
                setValue = Setting(iter: .none, set1: isPressed[1], widget: isPressed[2])

            }else{
                
                isPressed = [true,
                             CoreDataManager.shared.getSetting(idx: idx).set1,
                             CoreDataManager.shared.getSetting(idx: idx).widget]
                switch CoreDataManager.shared.getSetting(idx: idx).iter {
                case .week:
                    iterBtnPressed = [true, false, false]

                case .month:
                    iterBtnPressed = [false, true, false]

                case .year:
                    iterBtnPressed = [false, false, true]
                default:
                    iterBtnPressed = [false, false, false]

                }
                
                setValue = Setting(iter: CoreDataManager.shared.getSetting(idx: idx).iter, set1: isPressed[1], widget: isPressed[2])

            }

        }
    }
    
    @IBAction func textDidChanged(_ sender: Any){
        checkMaxLength(textField: inputname, maxLength: 10)
    }
    
    @IBAction func changeDatePIcker(_ sender: UIDatePicker) {
        let datePickerView = sender
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd EEE"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")


        showPickerTime.text = formatter.string(from: datePickerView.date)
        selectDate = formatter.date(from: formatter.string(from: datePickerView.date))!
    }
    
    
    @IBAction func saveDday(_ sender: UIButton){

        if(inputname.text == ""){ inputname.text = "이름 없음" }
        
        if(dele!.mode == "UPDATE"){
            updateDelegate?.sendUpdate(date: selectDate, name: inputname.text!, setting: setValue)
            
        }
        else{
            delegate?.send(date: selectDate, name: inputname.text!, setting: setValue, idx: CoreDataManager.shared.getCount())
        }
        

        NotificationCenter.default.post(name: DidDismissPostCommentViewController, object: nil, userInfo: nil)
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func updateDday(){

        let calculatedDday = CalculateDay.shared.calculateDday(select_day: selectDate, setting: setValue) //dday
        
        CoreDataManager.shared.updateEntity(data: rcvData(name: inputname.text!,
                                                          day: formatter.toString(date: selectDate),
                                                          dday: calculatedDday),
                                            idx: dele!.updateIdx)
        
        if(isPressed[0]==false){
            setValue.iter = .none
        }
        
        CoreDataManager.shared.updateSetting(setting: setValue, idx: dele!.updateIdx)
//        print("저장 후 저장된 값")
//        print(CoreDataManager.shared.getSetting(idx: dele!.updateIdx).iter)
    }
    
    //option + cmd + 화살표
    @objc func switchChanged(_ sender : UISwitch!){
    
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        
        switch sender.tag{
        case 0:
            print("iter")
            if !sender.isOn {
                setValue.iter = .none
            }

        case 1:
            sender.isOn ? (setValue.set1 = true) : (setValue.set1 = false)

        case 2:
            sender.isOn ? (setValue.widget = true) : (setValue.widget = false)
        
        default:
            setValue.iter = .none
            setValue.set1 = false
            setValue.widget = false
        }
        
        print( "변경된 switch", sender.tag)
        isPressed[sender.tag] = !isPressed[sender.tag]
        tableView.reloadData()
    }
    
    
    @objc func iterBtnClicked(_ sender: UIButton){
        print("sender: ", sender.tag, sender.isSelected)

        if (indexOfOneAndOnly != nil) && indexOfOneAndOnly != -1{ //하나라도 선택되어있을 때
            if !iterBtnPressed[sender.tag]{ //다른게 눌려져있으면
                for index in iterBtnPressed.indices{ //전부다 false로 만들고
                    iterBtnPressed[index] = false
                }
                
                iterBtnPressed[sender.tag] = true
                indexOfOneAndOnly = sender.tag
                setValue.iter = Iter(rawValue: sender.tag + 1)!

            }else{ //누른게 자기자신이라면
                iterBtnPressed[sender.tag] = false
                indexOfOneAndOnly = nil
                setValue.iter = Iter.none
            }

        }else{ //하나도 선택되어있지 않을 때
            iterBtnPressed[sender.tag] = true
            indexOfOneAndOnly = sender.tag
            setValue.iter = Iter(rawValue: sender.tag + 1)!

        }
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)] , with: .automatic)
    }

}

protocol SendProtocol{
    func send(date: Date, name: String, setting: Setting, idx: Int)
}

protocol SendUpdateProtocol{
    func sendUpdate(date: Date, name: String, setting: Setting)
}

extension Add: UITableViewDelegate, UITableViewDataSource{
    
    //table에 몇개의 section이 있을건지 알려줌
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    //section별로 몇개의 row가 있어야하는지
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return isPressed[section] ? 1:0
        }

        else {return 0}
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

    //헤더 셀의 높이
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    //footer 없애기
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        tableView.sectionFooterHeight = .leastNonzeroMagnitude

        return CGFloat.leastNonzeroMagnitude
    }
    

    
    //tableview에 넣을 cell을 직접적으로 요청하는 함수
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: self.iterIdentifier, for: indexPath) as! IterCell
        cell.selectionStyle = .none
        
        
        for i in 0...2{
            cell.iterButtons[i].tag = i
            cell.iterButtons[i].addTarget(self, action: #selector(self.iterBtnClicked(_:)), for: .touchUpInside)
            cell.iterButtons[i].isSelected = iterBtnPressed[i]
        }
        print("버튼 값", iterBtnPressed)

        return cell
        

    }
    
}

extension Add: UITextFieldDelegate{

    func checkMaxLength(textField: UITextField!, maxLength: Int) {
        inputname.delegate = self

        if ((textField.text?.count)! > 10) {
            textField.deleteBackward()
        }
    }

}
