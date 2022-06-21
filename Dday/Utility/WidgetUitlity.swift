//
//  WidgetUitlity.swift
//  Dday
//
//  Created by 한수진 on 2022/06/20.
//

import Foundation
import WidgetKit

class WidgetUtility {
    
    @objc func updateWidget() {
        print("update widget")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    static func save_widgetData() {
        print("save widget 실행")
        var collectData: [WidgetData] = []
        UserDefaults.shared.setValue(collectData, forKey: "data")

        for idx in 0..<CoreDataManager.shared.getCount() {
            if(CoreDataManager.shared.getSetting(idx: idx).widget){
                let name = CoreDataManager.shared.getEntity(key: "name", idx: idx)
                let dday = CoreDataManager.shared.getEntity(key: "dday", idx: idx)
                let set1 = CoreDataManager.shared.getSetting(idx: idx).set1

                collectData.append(WidgetData(name: name, dday: dday, set1: set1))
            }

        }
        
        if let encodedData = try? JSONEncoder().encode(collectData) {
            UserDefaults.shared.setValue(encodedData, forKey: "data")
        }
        WidgetCenter.shared.reloadTimelines(ofKind: "widget")

    }
}
