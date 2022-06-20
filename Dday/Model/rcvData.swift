//
//  rcvData.swift
//  Dday
//
//  Created by 한수진 on 2021/08/02.
//

import Foundation


class rcvData: Hashable {
    var name: String
    var day: String
    var dday: Int
    
    init(){
        name = ""
        day = ""
        dday = 0
    }
    init(name: String, day: String, dday:Int){
        self.name = name
        self.day = day
        self.dday = dday
    }
    
    static func == (lhs: rcvData, rhs: rcvData) -> Bool {
        return lhs == rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(day)
        hasher.combine(dday)
    }
    
    
}
