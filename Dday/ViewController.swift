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
    let userNotificationCenter = UNUserNotificationCenter.current()

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
        
        requestAuthorization()

        NotificationCenter.default.addObserver(self, selector: #selector(self.didDismissPostCommentNotification(_:)), name: DidDismissPostCommentViewController, object: nil)

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]){
            (result, error) in print(result)
        }
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(updatetime), userInfo: nil, repeats: true)
        //1분 60초
        //1시간 3600초
        //하루한번씩 체크는 86400

    }
    
    func requestAuthorization() {
        let options = UNAuthorizationOptions(arrayLiteral: .alert, .badge, .sound)
        userNotificationCenter.requestAuthorization(options: options) { success, error in
            if success {
                print("인증 요청 성공")
//                self.testnoti(seconds: 3)
            }
            if let error = error {
                print(error)
            }
        }
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

    }
    

    @objc func updatetime() {
        print("in update")
        let formatter = DateFormatter() // 특정 포맷으로 날짜를 보여주기 위한 변수 선언
        formatter.dateFormat = "yyyy-MM-dd HH:mm" // 날짜 포맷 지정
        
        if CoreDataManager.shared.getCount() > 0{
            for i in 0...(CoreDataManager.shared.getCount()-1){
                if Int(CoreDataManager.shared.getEntity(key: "dday", idx: i)) == 0  { // 디데이에 도달하면
                    print("dday~~~~")

                    ringAlarm(idx: i, today: true)
                }
                else if Int(CoreDataManager.shared.getEntity(key: "dday", idx: i)) == -1 { //디데이 전날
                    ringAlarm(idx: i, today: false)

                }
            }
        }
    }
    
    func add(data: rcvData, setting: Setting, idx: Int){
        collectionView.reloadData()
        CoreDataManager.shared.saveEntity(data: data, idx: idx)
        CoreDataManager.shared.saveSetting(setting: setting)
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")

        var dateComponents = DateComponents(hour: 21, minute: 13) //8시로 설정
        print("comp", dateComponents)
        
        if today{
            content.body = "dday입니다!!!"
        }
        else{
            content.body = "dday 전날입니다~~"
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        userNotificationCenter.add(request) { error in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
        
    }
 
}

class data: UICollectionViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var dday: UILabel!
}

extension ViewController:  UICollectionViewDataSource, UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout{
    
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
        let set1 = CoreDataManager.shared.getSetting(idx: indexPath.row).set1
        
        if(set1){
            if (Int(cellDday)!<0){
                cell.dday.text =  String(abs(Int(cellDday)!)) + "전"
            }
            else{
                cell.dday.text = String(cellDday) + "일"
            }

        }else{
            if (Int(cellDday)!<0){
                cell.dday.text = "D" + String(cellDday)
            }
            else if(Int(cellDday) == 0){
                cell.dday.text = "D-day"
            }
            else{
                cell.dday.text = "D+" + String(cellDday)
            }
        }
        
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.contentView.isUserInteractionEnabled = true


        print("setting value")
        print(CoreDataManager.shared.getEntity(key: "name", idx: indexPath.row))
        print(CoreDataManager.shared.getSetting(idx: indexPath.row).iter, "\n")

        
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(!CoreDataManager.shared.getSetting(idx: indexPath.row).set1 &&
            Int(CoreDataManager.shared.getEntity(key: "dday", idx: indexPath.row))!>0 &&
            UserDefaults.standard.bool(forKey: "hide")){
            return CGSize(width: 350, height: 0)
        }else{
            let width = (self.view.frame.size.width - 30) //some width
            let height = width * 0.3 //ratio
            return CGSize(width: 350, height: 116)

        }

    }
    
}

extension ViewController: SendProtocol{
    
    func send(date: Date, name: String, setting: Setting, idx: Int) { //5
        print("in main 저장 프로토콜")
        let formatter = DateFormatter()
        let result = CalculateDay.shared.calculateDday(d_day: date, setting: setting)
        formatter.dateFormat = "yyyy.MM.dd EEE"
//        CoreDataManager.shared.saveSetting(setting: setting)
        add(data: rcvData(name: name, day: formatter.string(from: date), dday: result), setting: setting, idx: idx)
    }
    
}

/*
extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .badge, .sound, .banner])
        //        completionHandler([.alert, .badge, .sound])
    }
}
*/
/*

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent noti: UNNotification,
                                withCompletionHandler completionHandler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
        
    }
    
}
 */

