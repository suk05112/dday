//
//  ViewController.swift
//  Dday
//
//  Created by 한수진 on 2021/07/19.
//

import UIKit
import UserNotifications


class ViewController: UIViewController {

    var dataList = [rcvData]()
    var setting = [Setting]()
    
    var numberOfCell: Int = 0
    var cellIdentifier: String = "cell"
    var rcvIdx: IndexPath = [-1, -1]
    
    let cal = Calendar(identifier: .gregorian)
    let formatter = DateFormatter()

    @IBOutlet weak var collectionView: UICollectionView!
    

    
    /*
    @IBAction func send(){
        let content = UNMutableNotificationContent()
        content.title = "제목"
        content.body = "내용"
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    */
    

    override func viewDidLoad() { //1
//        print("load")
        if (rcvIdx.row != -1){
//            print("appear remove")
            removeData(indexPath: rcvIdx)
        }
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        formatter.dateFormat = "yyyy-MM-dd"

        dataList.append(rcvData(name: "name", day: "0", dday: 0))

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]){
            (result, error) in print(result)
        }
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updatetime), userInfo: nil, repeats: true)
        //하루한번씩 체크는 86400

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //3
//        print("prepare")
        if segue.identifier == "show" {
            let viewController : Add = segue.destination as! Add
                viewController.delegate = self
            print("seg show")
        }
        
        if segue.identifier == "DetailVC"{
            let detail : Detail = segue.destination as! Detail
//            print("detail show")
            if let cell = sender as? UICollectionViewCell,
               let indexPath = self.collectionView.indexPath(for: cell) {
                detail.data = dataList[indexPath.row]
                detail.idx = indexPath
            }
        }
    }
    
    @objc func updatetime() {
        let formatter = DateFormatter() // 특정 포맷으로 날짜를 보여주기 위한 변수 선언
        formatter.dateFormat = "yyyy-MM-dd HH:mm" // 날짜 포맷 지정
        
        if dataList.count > 0{
            print("in update")
            if dataList[0].dday == 0  { // 디데이에 도달하면
                print("update")

                ringAlarm()
            }
        }
    }
    
    func add(){
        self.numberOfCell += 1
        collectionView.reloadData()
    }
    
    func removeData(indexPath: IndexPath) {
        dataList.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        self.numberOfCell -= 1
        rcvIdx = [-1, -1]
//        print("data remove!!")
    }

    func ringAlarm(){
        print("ring")

        let content = UNMutableNotificationContent()
        content.title = "제목"
        content.body = "내용"
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func calculateDday(d_day: Date, setting: Setting) -> Int{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        var alarm_list:Array<Date> = Array<Date>()
        var returnDay:Int = 0

        let today = Date()
        guard let distanceSecond = Calendar.current.dateComponents([.hour], from: d_day, to: today).hour else { return 0 }
        print("distance = ", distanceSecond/24)
        
        //보여질 디데이 계산
        returnDay = iterCalculator(setting: setting, d_day: d_day)

        
        //알림있을 경우 -> d+ 일때만 활성화
        if setting.alarm[0].on == true{
            
            if setting.alarm[1].on == true{ //dday
                alarm_list.append(d_day)
            }
            if setting.alarm[2].on == true{ //100
                let dayOffset = DateComponents(day: 99)
                alarm_list.append(cal.date(byAdding: dayOffset, to: d_day)!)
                //100일 계산
            }
            if setting.alarm[3].on == true{ //year
                let dayOffset = DateComponents(day: 364)
                alarm_list.append(cal.date(byAdding: dayOffset, to: d_day)!)
//                1년 계산
            }
            //알람시간 == 현재시간

        }
        

        //set1인 경우
        
        //위젯인 경우
        if setting.widget == true{
            
        }


        return setting.set1 ? returnDay: set1(settingDay: returnDay)

    }
    
    func iterCalculator(setting: Setting, d_day: Date)->Int{
        let today = Date()
        guard let distanceSecond = Calendar.current.dateComponents([.hour], from: d_day, to: today).hour else { return 0 }

        
        let dday_day = cal.dateComponents([.day], from: d_day).day!

        
        switch setting.iter {

            case .none:
                if formatter.string(from: d_day) == formatter.string(from: today){ //today == dday
                    return 0
                }
                else if ceil(Double(distanceSecond/24)) <= 0 { //before dday
                    print("before")
                    return (distanceSecond/24) - 1 //set1 적용안함
                }
                else{ //after dday
                    print("after")
                    return (distanceSecond/24)
                }
                
            case .week:
                let dday_week = cal.dateComponents([.weekday], from: d_day).weekday!
                let todayWeek = cal.dateComponents([.weekday], from: today).weekday!
               
                return 7-Int((todayWeek - dday_week).magnitude)
                
            case .month:
                
                let dday_offsetComps = cal.dateComponents([.year,.month,.day], from:d_day)
                let today_offsetComps = cal.dateComponents([.year,.month,.day], from:today)

                let lastday = lastDay(ofMonth: dday_offsetComps.month!, year: dday_offsetComps.year!)
                let iter_month = lastday<dday_offsetComps.day! ? lastday : dday_offsetComps.day!

                             
                if today_offsetComps.day! < iter_month{ //오늘 날짜가 반복 날짜보다 작을경우
                    print("작을 경우")
                    return iter_month - today_offsetComps.day!
                }
                else if today_offsetComps.day! > iter_month{ //오늘 날짜가 반복날짜를 지났을 경우(다음달이 디데이인경우)
                    print("클 경우")
                    var returnIterMonth = ""
                    if today_offsetComps.month! == 12{//이번달이 12월인경우

                        returnIterMonth = String(today_offsetComps.year! + 1)+"-1-"+String(dday_offsetComps.day!)
                    }
                    else{
                        returnIterMonth = String(today_offsetComps.year!) + "-" +
                                            String(today_offsetComps.month! + 1) + "-" +
                                            String(dday_offsetComps.day!)

                    }
                    print("월 반복", Int(formatter.date(from: returnIterMonth)!.timeIntervalSince(today) / 86400))
                    return Int(formatter.date(from: returnIterMonth)!.timeIntervalSince(today) / 86400)
                }
                else{ //} if today_offsetComps.day! == iter_month{ //dday
                    print("같을 경우")
                    return 0
                }

//                print("마지막날", lastday)
                
            case .year:
                return ((distanceSecond/24)%365)

        }
        print("dday_day", dday_day)
        return 0
    }
    
    func set1(settingDay: Int) -> Int{
        return settingDay + 1
    }
    
    
    func lastDay(ofMonth m: Int, year y: Int) -> Int {
        let cal = Calendar.current
        var comps = DateComponents(calendar: cal, year: y, month: m)
        comps.setValue(m + 1, for: .month)
        comps.setValue(0, for: .day)
        let date = cal.date(from: comps)!
        return cal.component(.day, from: date)
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
//        print("init")
        print(setting)
        return self.numberOfCell
    }
    
    //컬렉션뷰의 지정된 위치에 표시할 셀을 요청하는 메서드
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? data else {
            return UICollectionViewCell()
        }
//        print(dataList.count)
//        print("idxrow ", indexPath.row)
        
        if !dataList.isEmpty{
            cell.day.text = dataList[indexPath.row].day
            cell.name.text = dataList[indexPath.row].name
            cell.dday.text = String(dataList[indexPath.row].dday)
        }
        
        cell.contentView.isUserInteractionEnabled = true

//        print("setting idx ", indexPath.row)
        print("my iter", setting[indexPath.row].iter)
//        print("my alarm", setting[indexPath.row].alarm)
//        print("my widget", setting[indexPath.row].widget)
//        print("my set1", setting[indexPath.row].set1)


        return cell
    }
    
    /*
    //cell 누를때마다 호출
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)  {
        print("idxpath", indexPath.row)
        print("Cell \(indexPath.row + 1) clicked")
        print(dataList.count)
        print("rcvidx=",rcvIdx)
    }

    */
}

extension ViewController: SendProtocol{
    
    func send(date: Date, name: String, setting: Setting) { //5
        let formatter = DateFormatter()
        let result = calculateDday(d_day: date, setting: setting)
        formatter.dateFormat = "yyyy.MM.dd EEE"
        dataList.append(rcvData(name: name, day: formatter.string(from: date), dday: result))
        self.setting.append(setting)

        add()
    }
    
}

