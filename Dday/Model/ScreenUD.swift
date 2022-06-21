//
//  screenUD.swift
//  Dday
//
//  Created by 한수진 on 2021/09/23.
//

import Foundation

class ScreenUD : NSObject ,NSCoding {
    var hideDday: Bool
    var sortDday: Bool
    var notiBeforeDday: Bool

    
    init(hideDday: Bool, sortDday: Bool, notiBeforeDday: Bool) {
        self.hideDday = hideDday
        self.sortDday = sortDday
        self.notiBeforeDday = notiBeforeDday
    } //NSCoding Protocol 구현
    
    required init?(coder: NSCoder) {
        self.hideDday = coder.decodeObject(forKey: "hide") as! Bool
        self.sortDday = coder.decodeObject(forKey: "sort") as! Bool
        self.notiBeforeDday = coder.decodeObject(forKey: "noti") as! Bool
    }
    
    func encode(with coder: NSCoder) {
        self.hideDday = (coder.decodeObject(forKey: "hide") != nil)
        self.sortDday = (coder.decodeObject(forKey: "sort") != nil)
        self.notiBeforeDday = (coder.decodeObject(forKey: "noti") != nil)
    }

}
