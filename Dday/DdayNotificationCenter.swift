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
        let dateComponents = DateComponents(hour: 2, minute: 52) //8시로 설정
//        print("comp", dateComponents)
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
            content.body = "dday입니다!!!"
        }
        else{
            content.body = "dday 전날입니다~~"
        }
        
        return content
    
    }
    
    
    func removeNotification(idx: Int){
        print("noti 삭제 됨")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [String(idx)])

    }
}
