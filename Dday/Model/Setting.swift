//
//  Setting.swift
//  Dday
//
//  Created by 한수진 on 2021/08/06.
//

import Foundation

class Setting {

    var iter: Iter = .none
    var set1: Bool //true, false
    var widget: Bool //true, false
    
    init(){
        iter = .none
        set1 = false
        widget = false
    }
    
    init(iter: Iter, set1: Bool, widget: Bool){
        self.iter = iter
        self.set1 = set1
        self.widget = widget
    }
}

enum Iter: Int{
    case none
    case week
    case month
    case year

    func description() -> String {
        switch self {
        case .none:
          return "none"
        case .week:
          return "week"
        case .month:
          return "month"
        case .year:
          return "year"
        }
    }
    
    func kor() -> String {
        switch self {
        case .none:
          return "none"
        case .week:
          return "매주 반복"
        case .month:
          return "매월 반복"
        case .year:
          return "매년 반복"
        }
    }
    
    func pressedBtn() -> [Bool]{
        switch self {
        case .none:
          return [false, false, false]
        case .week:
          return [true, false, false]
        case .month:
          return [false, true, false]
        case .year:
          return [false, false, true]
        }
    }
}

enum Alarm: Int{
    case none
    case dday
    case hundred
    case year
}

