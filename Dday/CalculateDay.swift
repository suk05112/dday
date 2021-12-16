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
    let formatter = DdayDateFormmater()

    func calculateDday(select_day: Date, setting: Setting) -> Int{
        

        //보여질 디데이 계산
        var calculatedDday = iterCalculator(setting: setting, d_day: select_day)
        var targetDay = getTargetDay(dday: calculatedDday, set1: setting.set1)
        /*
<<<<<<< HEAD
=======
        
        //위젯인 경우
        if setting.widget == true{
            
        }
>>>>>>> parent of b2dca7b (삭제오류 해결)
         */
        
        //set1 설정
        if setting.set1{
            calculatedDday = set1(settingDay: calculatedDday)
        }
        
        return calculatedDday
        
    }
    
    func iterCalculator(setting: Setting, d_day: Date)->Int{
        
        var today = Date()
        let nowDateStr = formatter.toString(date: today)
        let nowDate = formatter.toDate(str: nowDateStr)
        
        let myDdayStr = formatter.toString(date: d_day)
        var myDday = formatter.toDate(str: myDdayStr) // 시간을 제외한 목표날짜
        
        today = nowDate

//        guard let distance = Calendar.current.dateComponents([.hour], from: d_day, to: today).hour else { return 0 }
        var distance = Calendar.current.dateComponents([.day], from: myDday, to: today).day!

        
        switch setting.iter {

            case .none:
                if ceil(Double(distance)) < 0 { //before dday
                    return -Int(((distance)).magnitude)
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

                    return -Int((formatter.toDate(str: returnIterMonth).timeIntervalSince(today) / 86400).magnitude)
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
    
    func getTargetDay(dday: Int, set1: Bool) -> Date{
        
        if set1 && (dday>0){
            return Calendar.current.date(byAdding: .day, value: (-dday+1), to: Date())!
            
        }
        else{
            return Calendar.current.date(byAdding: .day, value: -dday, to: Date())!

        }
        
    }
}
