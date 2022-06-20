//
//  DdayDateFormmater.swift
//  Dday
//
//  Created by 한수진 on 2021/12/16.
//

import Foundation

class DdayDateFormmater{
    static let shared = DdayDateFormmater()
    let formatter = DateFormatter()

    init(){
        formatter.dateFormat = "yyyy-MM-dd EEE"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")
    }
    
    func toString(date: Date) -> String{
        return formatter.string(from: date)
    }
    
    func toDate(str: String) -> Date{
        return formatter.date(from: str)!
    }
}
