//
//  Add.swift
//  Dday
//
//  Created by 한수진 on 2021/07/22.
//

import UIKit

class Add: UIViewController {

    @IBOutlet var showPickerTime: UILabel!
    var delegate : SendProtocol?
    var selectDate =  Date()
//    @IBOutlet var ddayname: String? = ""
    
    @IBOutlet weak var inputname: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func changeDatePIcker(_ sender: UIDatePicker) {
        let datePickerView = sender
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd EEE"
        showPickerTime.text = "선택시간: " + formatter.string(from: datePickerView.date)
        selectDate = formatter.date(from: formatter.string(from: datePickerView.date))!
    }
    
    
    @IBAction func saveDday(_ sender: UIButton){
        delegate?.send(date: selectDate, name: inputname.text!)
        print("seldate", selectDate)

        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true,
                completion: nil)
    }
    
}
protocol SendProtocol{
    func send(date: Date, name: String)
}
