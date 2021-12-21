//
//  Detail.swift
//  Dday
//
//  Created by 한수진 on 2021/08/02.
//

import UIKit


class Detail: UIViewController {
    
    @IBOutlet weak var detail_name: UILabel!
    @IBOutlet weak var detail_dday: UILabel!
    @IBOutlet weak var detail_day: UILabel!
    @IBOutlet weak var iterSet: UILabel!
    

    var data: rcvData = rcvData.init(name: "init name", day: "init day", dday: 0)
//    var idx:IndexPath = [-1, -1]
    var idx:Int = -1
    var setting: Setting = Setting(iter: .none, set1: false, widget: false)
    let delegate = UIApplication.shared.delegate as? AppDelegate
    
    
    let DidDismissPostCommentViewController: Notification.Name = Notification.Name("DidDismissPostCommentViewController")

    override func viewDidLoad() {
        super.viewDidLoad()


        loadData()
        
        print(CoreDataManager.shared.getSetting(idx: idx).iter)
        print(CoreDataManager.shared.getSetting(idx: idx).set1)
        print(CoreDataManager.shared.getSetting(idx: idx).widget)

        NotificationCenter.default.addObserver(self, selector: #selector(self.didDismissPostCommentNotification(_:)), name: DidDismissPostCommentViewController, object: nil)

    }


    override func viewDidDisappear(_ animated: Bool) {
        print("disappear")

        NotificationCenter.default.post(name: DidDismissPostCommentViewController, object: nil, userInfo: nil)

    }
    @objc func didDismissPostCommentNotification(_ noti: Notification) {
        loadData()

    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit" {
            let viewController : Add = segue.destination as! Add
//            viewController.delegate = self
            viewController.updateDelegate = self
            
            print("edit show")
        }
    }
    
    func getfilterdIndexByset1() -> [Int]{
        
        let numOfdata = CoreDataManager.shared.getCount()
        var filteredIdx:[Int] = []
        
        if(UserDefaults.standard.bool(forKey: "hide")){
            for i in 0..<numOfdata{
                if(CoreDataManager.shared.getSetting(idx: i).set1 ||
                    Int(CoreDataManager.shared.getEntity(key: "dday", idx: i))! < 1){
                    
                    filteredIdx.append(i)
                }
            
            }
        }
        else{
            filteredIdx = Array(0..<numOfdata)
        }

        return filteredIdx
    }

    func loadData(){
        
        print("filterd list")
        print(getfilterdIndexByset1())
//        let index:Int = getfilterdIndexByset1()[self.idx]
//        let index = getfilterdIndexByset1()[idx]

        setting = CoreDataManager.shared.getSetting(idx: self.idx)
        self.detail_name.text = CoreDataManager.shared.getEntity(key: "name", idx: self.idx)
        self.detail_day.text = CoreDataManager.shared.getEntity(key: "day", idx: self.idx)
        
        let dday = CoreDataManager.shared.getEntity(key: "dday", idx: self.idx)
        let set1 = CoreDataManager.shared.getSetting(idx: self.idx).set1
        
        if(set1){
            if (Int(dday)!<0){
                self.detail_dday.text = "D-" + String(abs(Int(dday)!))
            }
            else{
                self.detail_dday.text = String(dday) + "일"

            }

        }
        else{
            print("set1 false dday 표시", dday, data.dday)
            if (Int(dday)!<0){
                self.detail_dday.text = "D" + String(dday)
            }
            else if(Int(dday) == 0){
                self.detail_dday.text = "D-day"
            }
            else{
                self.detail_dday.text = "D+" + String(dday)

            }
        }

        
        switch setting.iter {
        case .week:
            self.iterSet.text = "매주 반복"
        case .month:
            self.iterSet.text = "매월 반복"
        case .year:
            self.iterSet.text = "매년 반복"
        default:
            self.iterSet.text = " "
            
        }
        
    }
    @IBAction func edit(_ sender: Any) {
//          self.presentingViewController?.dismiss(animated: true)
        
//        let index:Int = getfilterdIndexByset1()[self.idx]

        delegate?.mode = "UPDATE"
        delegate?.updateIdx = self.idx
        let viewControllerName = self.storyboard?.instantiateViewController(withIdentifier: "edit")
        viewControllerName?.modalTransitionStyle = .flipHorizontal
        if let view = viewControllerName {
            self.present(view, animated: true, completion: nil)
        }
      }
    
    @IBAction func remove(_ sender: Any){
        let alert = UIAlertController(title: "알림", message: "삭제하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
       
        let okAction = UIAlertAction(title: "네", style: .default) { (action) in
            print("say yes")
            let mainVC = self.presentingViewController
            guard let vc = mainVC as? ViewController else {return}
//            vc.rcvIdx = self.idx
            vc.rcvIdx = IndexPath(row: self.idx, section: 0)
            self.dismiss(animated: true) {
                print("dismiss")
                vc.viewDidLoad()
                    }
//            self.presentingViewController?.dismiss(animated: true)
        }
        
        let noAction = UIAlertAction(title: "아니요", style: .default) { (action) in
            }
        
        alert.addAction(okAction)
        alert.addAction(noAction)

        present(alert, animated: false, completion: nil)
//        self.presentingViewController?.dismiss(animated: true)

    }

    func sendDetailData(data: rcvData, idx: IndexPath) {
        self.data = data
        self.idx = idx.row
        print("data=",data)
    }

}

extension Detail: SendUpdateProtocol{
    
    func sendUpdate(date: Date, name: String, setting: Setting) {
        print("detail sendProtocol")
        let formatter = DateFormatter()
        let result = CalculateDay.shared.calculateDday(select_day: date, setting: setting)
        formatter.dateFormat = "yyyy.MM.dd EEE"
        //코어데이터 업데이트
//        CoreDataManager.shared.updateSetting(setting: setting)
        
        let index:Int = getfilterdIndexByset1()[idx]

        CoreDataManager.shared.updateEntity(data: rcvData(name: name, day: formatter.string(from: date), dday: result), idx: index)

    }
    
}


