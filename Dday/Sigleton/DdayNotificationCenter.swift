//
//  DdayNotificationCenter.swift
//  Dday
//
//  Created by 한수진 on 2021/11/23.
//

import Foundation
import UserNotifications

class DdayNotificationCenter{
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    func initNotification(){
        requestAuthorization()
    }
    
    func requestAuthorization() {
        let options = UNAuthorizationOptions(arrayLiteral: .alert, .badge, .sound)
        userNotificationCenter.requestAuthorization(options: options) { success, error in
            if success {
                print("인증 요청 성공")
            }
            if let error = error {
                print(error)
            }
        }
    }
    
    func setNoticifation(i: Int){

        if Int(CoreDataManager.shared.getEntity(key: "dday", idx: i)) == 0  { // 디데이에 도달하면
            print("dday~~~~")
            ringAlarm(idx: i, today: true)
        }
        else if Int(CoreDataManager.shared.getEntity(key: "dday", idx: i)) == -1 { //디데이 전날
            print("dday 전날")

            if(UserDefaults.standard.bool(forKey: "noti")){
                ringAlarm(idx: i, today: false)

            }

        }

    }
    
    func ringAlarm(idx: Int, today: Bool){
        
        
        let content = setContent(idx: idx, today: today)
        
        let dday = CoreDataManager.shared.getEntity(key: "dday", idx: idx)
        let set1 = CoreDataManager.shared.getSetting(idx: idx).set1
        
        let date = CalculateDay.shared.getTargetDay(dday: Int(dday)!, set1: set1)
        
        let year = Calendar.current.dateComponents([.year], from: date).year
        let month = Calendar.current.dateComponents([.month], from: date).month
        let day = Calendar.current.dateComponents([.day], from: date).day

        
        let dateComponents = DateComponents(year: year, month: month, day: day, hour: 8, minute: 00) //8시로 설정
//        let dateComponents = DateComponents(hour: 3, minute: 00) //8시로 설정
        
        print("noti 설정")
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: String(idx), content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                
        userNotificationCenter.add(request) { error in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
        
    }
    


    func setContent(idx: Int, today: Bool) -> UNMutableNotificationContent{
        let content = UNMutableNotificationContent()
        
        content.title = CoreDataManager.shared.getEntity(key: "name", idx: idx)
        if today{
            content.body = "notiDday".localized()
        }
        else{
            content.body = "notiBeforeDday".localized()
        }
        
        return content
    
    }
    
    
    func removeNotification(idx: Int){
        print("noti 삭제 됨")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [String(idx)])

    }
}
