//
//  CalculateDay.swift
//  Dday
//
//  Created by 한수진 on 2021/09/13.
//

import Foundation

class CalculateDay{
    static let shared = CalculateDay()
    private init() { }
    let cal = Calendar(identifier: .gregorian)

    func calculateDday(d_day: Date, setting: Setting) -> Int{
        
        var returnDay:Int = 0
        
        //보여질 디데이 계산
        returnDay = iterCalculator(setting: setting, d_day: d_day)
        
        //위젯인 경우
        if setting.widget == true{
            
        }
        
        //set1 설정
        if setting.iter == .none { //기념일같이 오늘날짜가 디데이를 넘었을 때, 반복없고 기념일인데 디데이에서 오늘날짜를 넘었을 때(이건 없데이트의 문제)
            returnDay = setting.set1 ? set1(settingDay: returnDay) : returnDay
            return Date() < d_day ? -returnDay : returnDay
        }else{ //반복있을 때는 무조건 음수
            return -returnDay
        }
    }
    
    func iterCalculator(setting: Setting, d_day: Date)->Int{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
                
        let today = Date()
        guard let distanceSecond = Calendar.current.dateComponents([.hour], from: d_day, to: today).hour else { return 0 }

        
        switch setting.iter {

            case .none:
                if formatter.string(from: d_day) == formatter.string(from: today){ //today == dday
                    print("같음")
                    return 0
                }
                else if ceil(Double(distanceSecond/24)) <= 0 { //before dday
                    print("before")
                    return Int(((distanceSecond/24) - 1).magnitude)
                }
                else{ //after dday
                    print("after")
                    return Int((distanceSecond/24).magnitude)
                }
                
            case .week:
                let dday_week = cal.dateComponents([.weekday], from: d_day).weekday!
                let todayWeek = cal.dateComponents([.weekday], from: today).weekday!
               
                return 6-Int((todayWeek - dday_week).magnitude)
                
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
                    return Int((formatter.date(from: returnIterMonth)!.timeIntervalSince(today) / 86400).magnitude)
                }
                else{ //} if today_offsetComps.day! == iter_month{ //dday
                    print("같을 경우")
                    return 0
                }
                
            case .year:
                return -(distanceSecond/24)%365

        }
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
