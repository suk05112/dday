//
//  ViewController.swift
//  Dday
//
//  Created by 한수진 on 2021/07/19.
//

import UIKit
import UserNotifications
import CoreData

class ViewController: UIViewController {

    var numberOfCell: Int = 0
    var cellIdentifier: String = "cell"
    var rcvIdx: IndexPath = [-1, -1]
    
    let cal = Calendar(identifier: .gregorian)
    let formatter = DateFormatter()
    
    let delegate = UIApplication.shared.delegate as? AppDelegate
    let DidDismissPostCommentViewController: Notification.Name = Notification.Name("DidDismissPostCommentViewController")

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() { //1
        super.viewDidLoad()

//        CoreDataManager.shared.deleteAll()
        numberOfCell = CoreDataManager.shared.getCount()
        if (rcvIdx.row != -1){
            removeData(indexPath: rcvIdx)
        }

        collectionView.dataSource = self
        collectionView.delegate = self
        formatter.dateFormat = "yyyy-MM-dd"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didDismissPostCommentNotification(_:)), name: DidDismissPostCommentViewController, object: nil)

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]){
            (result, error) in print(result)
        }
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updatetime), userInfo: nil, repeats: true)
        //하루한번씩 체크는 86400

    }
    @objc func didDismissPostCommentNotification(_ noti: Notification) {
        print("함수 안!!")
        collectionView.reloadData()

    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //3
//        print("prepare")
        if segue.identifier == "show" {
            delegate?.mode = "CREATE"
            let viewController : Add = segue.destination as! Add
                viewController.delegate = self
            
            print("seg show")
        }
        
        if segue.identifier == "DetailVC"{
            let detail : Detail = segue.destination as! Detail
//            print("detail show")
            if let cell = sender as? UICollectionViewCell,
               let indexPath = self.collectionView.indexPath(for: cell) {
                detail.data = rcvData(name: CoreDataManager.shared.getEntity(key: "name", idx: indexPath.row),
                                      day: CoreDataManager.shared.getEntity(key: "day", idx: indexPath.row),
                                      dday: Int(CoreDataManager.shared.getEntity(key: "dday", idx: indexPath.row))!)
                detail.idx = indexPath
                detail.setting = CoreDataManager.shared.getSetting(idx: indexPath.row)

            }
        }
    }
    public func presentationControllerDidDismiss(
      _ presentationController: UIPresentationController)
    {
        print("함수 호출됨")
      // Only called when the sheet is dismissed by DRAGGING.
      // You'll need something extra if you call .dismiss() on the child.
      // (I found that overriding dismiss in the child and calling
      // presentationController.delegate?.presentationControllerDidDismiss
      // works well).
    }

    @objc func updatetime() {

        let formatter = DateFormatter() // 특정 포맷으로 날짜를 보여주기 위한 변수 선언
        formatter.dateFormat = "yyyy-MM-dd HH:mm" // 날짜 포맷 지정
        
        if CoreDataManager.shared.getCount() > 0{
            for i in 0...(CoreDataManager.shared.getCount()-1){
                if Int(CoreDataManager.shared.getEntity(key: "dday", idx: i)) == 0  { // 디데이에 도달하면
                    ringAlarm(idx: i, today: true)
                }
                else if Int(CoreDataManager.shared.getEntity(key: "dday", idx: i)) == -1 { //디데이 전날
                    ringAlarm(idx: i, today: false)

                }
            }
        }
    }
    
    func add(data: rcvData){
        collectionView.reloadData()
        CoreDataManager.shared.saveEntity(data: data)
        self.numberOfCell += 1
    }
    
    func removeData(indexPath: IndexPath) {
        CoreDataManager.shared.deleteEntity(idx: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        self.numberOfCell -= 1
        rcvIdx = [-1, -1]
    }

    func ringAlarm(idx: Int, today: Bool){
        let content = UNMutableNotificationContent()
        content.title = CoreDataManager.shared.getEntity(key: "name", idx: idx)
        if today{
            content.body = "dday입니다!!!"
        }
        else{
            content.body = "dday 전날입니다~~"
        }
        content.badge = 0
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
 
}

class data: UICollectionViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var dday: UILabel!
}

extension ViewController:  UICollectionViewDataSource, UICollectionViewDelegate{
    
    //지정된 섹션에 표시할 항목의 개수를 묻는 메서드
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { //2
        return self.numberOfCell
    }
    
    //컬렉션뷰의 지정된 위치에 표시할 셀을 요청하는 메서드
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? data else {
            return UICollectionViewCell()
        }
        
        cell.day.text = CoreDataManager.shared.getEntity(key: "day", idx: indexPath.row)
        cell.name.text = CoreDataManager.shared.getEntity(key: "name", idx: indexPath.row)

        let cellDday = CoreDataManager.shared.getEntity(key: "dday", idx: indexPath.row)
        
        if (Int(cellDday)!<0){
            cell.dday.text = "D" + String(cellDday)
        }
        else if(Int(cellDday) == 0){
            cell.dday.text = "D-day"
        }
        else{
            cell.dday.text = "D+" + String(cellDday)

        }
        
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.contentView.isUserInteractionEnabled = true

        print("setting value")
        print(CoreDataManager.shared.getEntity(key: "name", idx: indexPath.row))
        print(CoreDataManager.shared.getSetting(idx: indexPath.row).iter, "\n")
//        print(CoreDataManager.shared.getSetting(idx: indexPath.row).set1)
//        print(CoreDataManager.shared.getSetting(idx: indexPath.row).widget)

        return cell
    }
    
}

extension ViewController: SendProtocol{
    
    func send(date: Date, name: String, setting: Setting) { //5
        print("in main 저장 프로토콜")
        let formatter = DateFormatter()
        let result = CalculateDay.shared.calculateDday(d_day: date, setting: setting)
        formatter.dateFormat = "yyyy.MM.dd EEE"
//        CoreDataManager.shared.saveSetting(setting: setting)
        add(data: rcvData(name: name, day: formatter.string(from: date), dday: result))
    }
    
}
