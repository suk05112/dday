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
    let ddayNoti = DdayNotificationCenter()

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() { //1
        super.viewDidLoad()
        save_widgetData()
        getUserdata()
        updateDday()
        
        UserDefaults.shared.set("this is widget test", forKey: "test")

//        CoreDataManager.shared.deleteAll()
        numberOfCell = CoreDataManager.shared.getCount()
        if (rcvIdx.row != -1){
            removeData(indexPath: rcvIdx)
        }

        collectionView.dataSource = self
        collectionView.delegate = self
        formatter.dateFormat = "yyyy-MM-dd"
        
        ddayNoti.initNotification()
        NotificationCenter.default.addObserver(self, selector: #selector(self.didDismissPostCommentNotification(_:)), name: DidDismissPostCommentViewController, object: nil)

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]){
            (result, error) in print(result)
        }
        Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(updatetime), userInfo: nil, repeats: true)
        //1분 60초
        //1시간 3600초
        //하루한번씩 체크는 86400
        
    }
    
    func updateDday(){
        for i in 0..<CoreDataManager.shared.getCount(){
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd EEE"

            let targetDay = formatter.date(from: CoreDataManager.shared.getEntity(key: "day", idx: i))
            print("target day = ", CoreDataManager.shared.getEntity(key: "day", idx: i))
            let updateDday = CalculateDay.shared.calculateDday(d_day: targetDay!,
                                                               setting: CoreDataManager.shared.getSetting(idx: i))
            CoreDataManager.shared.updateDday(dday: updateDday, idx: i)

        }
    }
    
    func getUserdata(){
        print("widget true인 값")
        guard
            var data = UserDefaults.shared.object(forKey: "data") as? Data,
            let decode = try? JSONDecoder().decode([WidgetData].self, from: data)
        else { return }
        print(decode)
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
                    ddayNoti.ringAlarm(idx: i, today: true)
                }
                else if Int(CoreDataManager.shared.getEntity(key: "dday", idx: i)) == -1 { //디데이 전날
                    print("dday 전날")

                    if(UserDefaults.standard.bool(forKey: "noti")){
                        ddayNoti.ringAlarm(idx: i, today: false)

                    }

                }
            }
        }
    }
    
    func save_widgetData(){
        var collectData:[WidgetData] = []
        
        for i in 0..<CoreDataManager.shared.getCount(){
            if(CoreDataManager.shared.getSetting(idx: i).widget){
                let name = CoreDataManager.shared.getEntity(key: "name", idx: i)
                let dday = CoreDataManager.shared.getEntity(key: "dday", idx: i)

                collectData.append(WidgetData(name: name, dday: dday))
            }

        }
        
        if let encoded_data = try? JSONEncoder().encode(collectData){
            UserDefaults.shared.setValue(encoded_data, forKey: "data")
        }
        
    }
    
    func add(data: rcvData, setting: Setting, idx: Int){
        collectionView.reloadData()
        print("추가하는 함수 안에서 넘어온 Dday", data.dday)
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
        cell.dday.textAlignment = .left
        
        let cellDday = CoreDataManager.shared.getEntity(key: "dday", idx: indexPath.row)
        let setting = CoreDataManager.shared.getSetting(idx: indexPath.row)
        
        if(setting.set1 && setting.iter == .none){
            if (Int(cellDday)!<0){
                cell.dday.text =  "D-" + String(abs(Int(cellDday)!))
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
        setCeelColor(idx: indexPath.row, cell: cell)
        setViewShadow(backView: cell)
//        cell.layer.cornerRadius = 10
//        cell.layer.masksToBounds = true
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

            return CGSize(width: 350, height: 80)

        }

    }
    
    //행 사이 간격 최소 간격을 반환
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
//    //셀 사이의 최소간격을 반환
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0.0
//    }
    
    func setCeelColor(idx: Int, cell: UIView){
        
        switch(idx%4){
            
            case 0:
                cell.backgroundColor = UIColor(red: CGFloat(255)/255.0, green: CGFloat(231)/255.0, blue: CGFloat(231)/255.0, alpha: 1.0)

            case 1:
                cell.backgroundColor = UIColor(red: CGFloat(250)/255.0, green: CGFloat(205)/255.0, blue: CGFloat(205)/255.0, alpha: 1.0)
            
            case 2:
                cell.backgroundColor = UIColor(red: CGFloat(248)/255.0, green: CGFloat(151)/255.0, blue: CGFloat(151)/255.0, alpha: 1.0)

            case 3:
                cell.backgroundColor = UIColor(red: CGFloat(255)/255.0, green: CGFloat(121)/255.0, blue: CGFloat(121)/255.0, alpha: 1.0)

            default:
                cell.backgroundColor = UIColor(red: CGFloat(0)/0.0, green: CGFloat(255)/255.0, blue: CGFloat(255)/255.0, alpha: 1.0)

        }
    }
    
    func setViewShadow(backView: UIView) {
        backView.layer.masksToBounds = true
        backView.layer.cornerRadius = 10
        
        backView.layer.masksToBounds = false
        backView.layer.shadowOpacity = 0.3
        backView.layer.shadowOffset = CGSize(width: -2, height: 2)
        backView.layer.shadowRadius = 3
    }
    
}

extension ViewController: SendProtocol{
    
    func send(date: Date, name: String, setting: Setting, idx: Int) { //5
        let formatter = DateFormatter()
        let result = CalculateDay.shared.calculateDday(d_day: date, setting: setting)
        print("result 받은 직후", result)
        formatter.dateFormat = "yyyy.MM.dd EEE"
        
        var target_date: Date
        
        if(result < 0){
            target_date = Calendar.current.date(byAdding: .day, value: Int(result.magnitude), to: Date())!
        }else{
            target_date = date
        }

        add(data: rcvData(name: name,
                          day: formatter.string(from: target_date),
                          dday: result),
            setting: setting, idx: idx)
    }
    
}

extension UserDefaults {
    static var shared: UserDefaults {
        // ✅ App Groups Identifier 를 저장하는 변수
        let appGroupID = "group.com.sujin.Dday"

        // ✅ 파라미터로 전달되는 이름의 기본값으로 초기화된 UserDefaults 개체를 만든다.
        // ✅ 이전까지 사용했던 standard UserDefaults 와 다르다. 공유되는 App Group Container 에 있는 저장소를 사용한다.
        // ✅ suitename : The domain identifier of the search list.
        return UserDefaults(suiteName: appGroupID)!
    }
}

