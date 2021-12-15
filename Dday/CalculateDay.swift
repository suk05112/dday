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

    func calculateDday(select_day: Date, setting: Setting) -> Int{

        //보여질 디데이 계산
        var calculatedDday = iterCalculator(setting: setting, d_day: select_day)
        var targetDay = getTargetDay(dday: calculatedDday)
        
        //위젯인 경우
        if setting.widget == true{
            
        }
        
        //set1 설정
        if setting.set1{
            calculatedDday = set1(settingDay: calculatedDday)
        }
        
        return calculatedDday
        
//        if setting.iter == .none { //기념일같이 오늘날짜가 디데이를 넘었을 때, 반복없고 기념일인데 디데이에서 오늘날짜를 넘었을 때(이건 없데이트의 문제)
//
//            return Date() < select_day ? -calculatedDday : calculatedDday
//        }else{ //반복있을 때는 무조건 음수, set1 무시
//            return -calculatedDday
//        }
    }
    
    func iterCalculator(setting: Setting, d_day: Date)->Int{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")

        var today = Date()
        let nowDateStr = formatter.string(from: today)
        let nowDate = formatter.date(from: nowDateStr)!
        
        let myDdayStr = formatter.string(from: d_day)
        var myDday = formatter.date(from: myDdayStr)! // 시간을 제외한 목표날짜
        
        today = nowDate

//        guard let distance = Calendar.current.dateComponents([.hour], from: d_day, to: today).hour else { return 0 }
        var distance = Calendar.current.dateComponents([.day], from: myDday, to: today).day!

        
        switch setting.iter {

            case .none:
                if ceil(Double(distance)) < 0 { //before dday
                    return -Int(((distance) - 1).magnitude)
                }
                else{ //after dday
                    return Int((distance).magnitude)
                }
                
            case .week:
                let dday_week = cal.dateComponents([.weekday], from: myDday).weekday!
                let todayWeek = cal.dateComponents([.weekday], from: today).weekday!

                if todayWeek<dday_week{
                    return todayWeek - dday_week
                }
                else{
                    return todayWeek-dday_week-7
                }
                
            case .month:
                
                let dday_offsetComps = cal.dateComponents([.year,.month,.day], from:myDday)
                let today_offsetComps = cal.dateComponents([.year,.month,.day], from:today)

                let lastday = lastDay(ofMonth: dday_offsetComps.month!, year: dday_offsetComps.year!)
                let iter_month = lastday<dday_offsetComps.day! ? lastday : dday_offsetComps.day!

                             
                if today_offsetComps.day! < iter_month{ //오늘 날짜가 반복 날짜보다 작을경우
                    print("작을 경우")
                    return -iter_month + today_offsetComps.day!
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

                    return -Int((formatter.date(from: returnIterMonth)!.timeIntervalSince(today) / 86400).magnitude)
                }
                else{
                    print("같을 경우")
                    return 0
                }
                
            case .year:

                var targetDay = myDday
                var distance_year: Int
                
                let this_year = Calendar.current.dateComponents([.year], from: Date()).year!
                let target_year = Calendar.current.dateComponents([.year], from: targetDay).year!
            
                targetDay = Calendar.current.date(byAdding: .year, value: this_year - target_year, to: myDday)!
                
                if targetDay > today{
                    targetDay = Calendar.current.date(byAdding: .year, value: 1, to: targetDay)!
                }

                distance_year = Calendar.current.dateComponents([.day], from: targetDay, to: today).day!
                let result = (Int(distance_year)%365)

                return result>0 ? (result-365):result
            

        }
    }
    
    func set1(settingDay: Int) -> Int{
        if(settingDay > -1){
            return settingDay + 1
        }
        else{
            return settingDay
        }
    }
    
    func lastDay(ofMonth m: Int, year y: Int) -> Int {
        let cal = Calendar.current
        var comps = DateComponents(calendar: cal, year: y, month: m)
        comps.setValue(m + 1, for: .month)
        comps.setValue(0, for: .day)
        let date = cal.date(from: comps)!
        return cal.component(.day, from: date)
    }
    
    func getTargetDay(dday: Int) -> Date{
        
        return Calendar.current.date(byAdding: .day, value: -dday, to: Date())!
    }
}
