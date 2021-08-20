//
//  Add.swift
//  Dday
//
//  Created by 한수진 on 2021/07/22.
//

import UIKit

class Add: UIViewController {

    @IBOutlet var showPickerTime: UILabel!
    @IBOutlet weak var inputname: UITextField!
    @IBOutlet weak var tableView: UITableView!



    
    let headerCellIdentifier = "headerCell"
    let iterIdentifier = "Itercell"
    let alarmIdentifier = "AlarmCell"
    
    var indexOfOneAndOnly: Int?
    var indexOfAlarm: Int?

    var iterBtnPressed:[Bool] = [false, false, false]
    var alarmBtnPressed:[Bool] = [false, false, false]
    
    let setting:[String] = ["반복", "알림", "설정일을 1일부터 시작", "위젯"]
//    var arm: [Alarm: Bool] = [.none: false, .dday: false, .hundred: false, .year: false]

//    let sortedArm = arm.sorted {$0.rawValue<$1.rawValue}
    var setValue = Setting(iter: .none,
                           alarm:[(arm:.none, on:false), (arm:.dday, on:false), (arm:.hundred, on:false), (arm:.year, on:false)],
                           set1: false,
                           widget: false)

    var isPressed:[Bool] = [false, false, false, false]
    
    var delegate : SendProtocol?
    var selectDate =  Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = false
        
        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableView.automaticDimension
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd EEE"
        
        showPickerTime.text = formatter.string(from: selectDate)
    }

    @IBAction func changeDatePIcker(_ sender: UIDatePicker) {
        let datePickerView = sender
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd EEE"
        showPickerTime.text = formatter.string(from: datePickerView.date)
        selectDate = formatter.date(from: formatter.string(from: datePickerView.date))!
    }
    
    
    @IBAction func saveDday(_ sender: UIButton){
        
        delegate?.send(date: selectDate, name: inputname.text!, setting: setValue)

        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true,
                completion: nil)
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
            print("alarm")
            sender.isOn ? (setValue.alarm[0].on = true) : (setValue.alarm[0].on = false)

        case 2:
            sender.isOn ? (setValue.set1 = true) : (setValue.set1 = false)

        case 3:
            sender.isOn ? (setValue.widget = true) : (setValue.widget = false)
        
        default:
            setValue.iter = .none
            setValue.alarm = [(arm:.none, on:false), (arm:.dday, on:false), (arm:.hundred, on:false), (arm:.year, on:false)]
            setValue.set1 = false
            setValue.widget = false
        }
        
        isPressed[sender.tag] = !isPressed[sender.tag]
        tableView.reloadData()
    }
    
    @objc func iterBtnClicked(_ sender: UIButton){
        
        if indexOfOneAndOnly != nil{ //하나라도 선택되어있을 때
            if !sender.isSelected{ //다른게 눌려져있으면
                for index in iterBtnPressed.indices{ //전부다 false로 만들고
                    iterBtnPressed[index] = false
                }
                sender.isSelected = true //선택한 것을 true로 만든다
                iterBtnPressed[sender.tag] = true
                indexOfOneAndOnly = sender.tag
                setValue.iter = Iter(rawValue: sender.tag + 1)!

            }else{ //누른게 자기자신이라면
                sender.isSelected = false
                iterBtnPressed[sender.tag] = false
                indexOfOneAndOnly = nil
                setValue.iter = Iter.none
            }

        }else{ //하나도 선택되어있지 않을 때
            sender.isSelected = true
            iterBtnPressed[sender.tag] = true
            indexOfOneAndOnly = sender.tag
            setValue.iter = Iter(rawValue: sender.tag + 1)!

        }
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)] , with: .automatic)
    }


    @objc func alarmBtnClicked(_ sender : UIButton!){

        setValue.alarm[sender.tag+1].on = !setValue.alarm[sender.tag+1].on
        sender.isSelected = !sender.isSelected
        alarmBtnPressed[sender.tag] = sender.isSelected
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)] , with: .automatic)
    }
}

protocol SendProtocol{
    func send(date: Date, name: String, setting: Setting)
}


extension Add: UITableViewDelegate, UITableViewDataSource{
    
    //table에 몇개의 section이 있을건지 알려줌
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    //section별로 몇개의 row가 있어야하는지
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("numberOfsectionRow")
        if(section == 0) {
            return isPressed[section] ? 1:0
        }
        else if(section == 1){
            return isPressed[section] ? 1:0
        }
        else {return 0}
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.headerCellIdentifier) as! HeaderCell
        let text = setting[section]

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
    
    //tableview에 넣을 cell을 직접적으로 요청하는 함수
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: self.iterIdentifier, for: indexPath) as! IterCell
            cell.selectionStyle = .none
            
            
            for i in 0...2{
                cell.iterButtons[i].tag = i
                cell.iterButtons[i].addTarget(self, action: #selector(self.iterBtnClicked(_:)), for: .touchUpInside)
                cell.iterButtons[i].isSelected = iterBtnPressed[i]
            }

            return cell
        }
        else {


            let cell = tableView.dequeueReusableCell(withIdentifier: self.alarmIdentifier, for: indexPath) as! AlarmCell
            cell.selectionStyle = .none
            
            for i in 0...2{
                cell.alarmButtons[i].tag = i
                cell.alarmButtons[i].addTarget(self, action: #selector(self.alarmBtnClicked(_:)), for: .touchUpInside)
                cell.alarmButtons[i].isSelected = alarmBtnPressed[i]
            }
            return cell

        }

    }
    
}
