//
//  Setting.swift
//  Dday
//
//  Created by 한수진 on 2021/08/06.
//

import Foundation

class Setting {

    var iter: Iter = .none
    var alarm: [(arm: Alarm, on: Bool)] = [(arm:.none, on:false), (arm:.dday, on:false), (arm:.hundred, on:false), (arm:.year, on:false)]
    var set1: Bool //true, false
    var widget: Bool //true, false
    
    init(iter: Iter, alarm: [(arm: Alarm, on: Bool)], set1: Bool, widget: Bool){
        self.iter = iter
        self.alarm = alarm
        self.set1 = set1
        self.widget = widget
    }
}

enum Iter: Int{
    case none
    case week
    case month
    case year
}

enum Alarm: Int{
    case none
    case dday
    case hundred
    case year
}

