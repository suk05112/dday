//
//  Setting.swift
//  Dday
//
//  Created by 한수진 on 2021/08/06.
//

import Foundation

class Setting {
//    var iter: Bool //none, week, month, year(non dupli)
//    var alarm: Bool //none, dday, hundred, year(dupli)
    var iter: Iter = .none
    var alarm: Alarm = .none
    var set1: Bool //true, false
    var widget: Bool //true, false
    
    init(iter: Iter, alarm: Alarm, set1: Bool, widget: Bool){
        self.iter = iter
        self.alarm = alarm
        self.set1 = set1
        self.widget = widget
    }
}

enum Iter{
    case none
    case week
    case month
    case year
}

enum Alarm{
    case none
    case dday
    case hundred
    case year
}

