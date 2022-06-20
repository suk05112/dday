//
//  WidgetUitlity.swift
//  Dday
//
//  Created by 한수진 on 2022/06/20.
//

import Foundation
import WidgetKit

class WidgetUtility{
    
    @objc func updateWidget() {
        print("update widget")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    static func save_widgetData(){
        print("save widget 실행")
        var collectData:[WidgetData] = []
        UserDefaults.shared.setValue(collectData, forKey: "data")

        
        for i in 0..<CoreDataManager.shared.getCount(){
            if(CoreDataManager.shared.getSetting(idx: i).widget){
                let name = CoreDataManager.shared.getEntity(key: "name", idx: i)
                let dday = CoreDataManager.shared.getEntity(key: "dday", idx: i)
                let set1 = CoreDataManager.shared.getSetting(idx: i).set1

                collectData.append(WidgetData(name: name, dday: dday, set1: set1))
            }

        }
        
        if let encoded_data = try? JSONEncoder().encode(collectData){
            UserDefaults.shared.setValue(encoded_data, forKey: "data")
        }
        WidgetCenter.shared.reloadTimelines(ofKind: "widget")

        
    }
}
