//
//  Item.swift
//  Dday
//
//  Created by 한수진 on 2022/06/20.
//

import Foundation

class Item{
    var idx: Int = 0
    var data = RecieveData()
    var name: String = ""
    var day: String = ""
    var dday: Int = 0
    
    var setting = Setting(iter: .none, set1: false, widget: false)
    
    let notification = DdayNotificationCenter()
    let dateFormatter = DdayDateFormatter.shared

    init(){
    }
    
    func add(data: RecieveData, setting: Setting, idx: Int){
//        let data = rcvData(name: name, day: day, dday: dday)
        CoreDataManager.shared.saveEntity(data: data, idx: idx)
        CoreDataManager.shared.saveSetting(setting: setting)
        
        WidgetUtility.save_widgetData()
    }
    
    func delete(idx: Int){
        CoreDataManager.shared.deleteEntity(idx: idx)
        CoreDataManager.shared.deleteSetting(idx: idx)
        WidgetUtility.save_widgetData()
    }
    
    func update(data: RecieveData, setting: Setting, idx: Int){
        CoreDataManager.shared.updateEntity(data: data, idx: idx)

        CoreDataManager.shared.updateSetting(setting: setting, idx: idx)
        notification.removeNotification(idx: idx)
        notification.setNoticifation(idx: idx)
        
        WidgetUtility.save_widgetData()

    }
    
    func getItemData(idx: Int) -> (String, String, String){
        let name = CoreDataManager.shared.getEntity(key: "name", idx: idx)
        let day = CoreDataManager.shared.getEntity(key: "day", idx: idx)
        let dday = CoreDataManager.shared.getEntity(key: "dday", idx: idx)
        
        return (name, day, dday)
    }
    
    func getItemSetting(idx: Int) -> Setting{
        return CoreDataManager.shared.getSetting(idx: idx)
    }
    
    func getDdayString(dday: Int, set1: Bool) ->  String{

        if (dday<0){
            return "D" + String(dday)
        }
        else if(dday == 0){
            return set1 ? "0일" : "D-day"
        }
        else{
            return set1 ? String(dday) + "일" : "D+" + String(dday)
        }

    }
}

