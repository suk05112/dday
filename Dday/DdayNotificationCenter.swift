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
//                self.testnoti(seconds: 3)
            }
            if let error = error {
                print(error)
            }
        }
    }
    
    func ringAlarm(idx: Int, today: Bool){
        
        let content = setContent(idx: idx, today: today)
        let dateComponents = DateComponents(hour: 22, minute: 06) //8시로 설정
        print("comp", dateComponents)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
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
}
