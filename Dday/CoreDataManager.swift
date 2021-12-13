//
//  CoreDataManager.swift
//  Dday
//
//  Created by 한수진 on 2021/09/08.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager {
    static let shared: CoreDataManager = CoreDataManager()
    
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    lazy var context = appDelegate?.persistentContainer.viewContext
    
    let entityName: String = "Entity"
    let settingName: String = "MySetting"
    
    func getEntity(key: String, idx: Int) ->String{
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        var results = try! context?.fetch(request)
        
        if(UserDefaults.standard.bool(forKey: "sort")){
            results = sortbyDday()
        }

        let record = results?[idx]
        
        let myrequest: NSFetchRequest<Entity> = Entity.fetchRequest()
        let myrecord = try! context?.fetch(myrequest)
        
        if(key != "dday"){
            return (record as AnyObject).value(forKey: key) as! String
        }
        else{
            return String((record as AnyObject).value(forKey: "dday") as! Int)
        }

    }
 
    func  deleteAll() {
        let requestEntity: NSFetchRequest<Entity> = Entity.fetchRequest()
        let requestSEtting: NSFetchRequest<MySetting> = MySetting.fetchRequest()

        do {
        
            let Entityresults = try! context?.fetch(requestEntity)
            let Settingresults = try! context?.fetch(requestSEtting)
            
            Entityresults!.forEach{
                context?.delete($0 as NSManagedObject)
            }
            Settingresults!.forEach{
                context?.delete($0 as NSManagedObject)
            }
            try context?.save()

        } catch {
            print(error)
            context?.rollback()
            print(error.localizedDescription)
        }
    }
    
    
    func saveEntity(data: rcvData, idx: Int) {
        if let context = context,
            let entity: NSEntityDescription
            = NSEntityDescription.entity(forEntityName: entityName, in: context) {
            
                let myentity = NSManagedObject(entity: entity, insertInto: context)
                myentity.setValue(data.name, forKey: "name")
                myentity.setValue(data.day, forKey: "day")
                myentity.setValue(data.dday, forKey: "dday")
                myentity.setValue(idx, forKey: "idx")

            }
            
            do {
                try context?.save()
            } catch {
                print(error.localizedDescription)
            }
    }
    
    func deleteEntity(idx: Int) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        let results = try! context?.fetch(request)
        context?.delete(results![idx] as! NSManagedObject)

        do {
            try context?.save()
        } catch {
            context?.rollback()
            print(error.localizedDescription)
        }

    }
    
    func updateEntity(data: rcvData, idx: Int){
        print("update Entity!!")
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        var myresult = [NSManagedObject]()
        let records = try! context!.fetch(request)
        
        if let records = records as? [NSManagedObject] {
            myresult = records
               }
        
        print(myresult[idx].setValue("바꾼 이름", forKey: "name"))
        myresult[idx].setValue(data.name, forKeyPath: "name")
        myresult[idx].setValue(data.day, forKeyPath: "day")
        myresult[idx].setValue(data.dday, forKeyPath: "dday")

        do {
            try context?.save()
        } catch {
            context?.rollback()
            print(error.localizedDescription)
        }

    }
    
    func updateDday(dday:Int, idx:Int){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        var myresult = [NSManagedObject]()
        let records = try! context!.fetch(request)
        
        if let records = records as? [NSManagedObject] {
            myresult = records
               }
        
        myresult[idx].setValue(dday, forKeyPath: "dday")

        do {
            try context?.save()
        } catch {
            context?.rollback()
            print(error.localizedDescription)
        }
    }

}

extension CoreDataManager {
    func getSetting(idx: Int) -> Setting {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: settingName)
        let results = try! context?.fetch(request)
        let record = results?[idx]

        return Setting(iter: Iter(rawValue: (record as AnyObject).value(forKey: "iter") as! Int)!,
                       set1: (record as AnyObject).value(forKey: "set1") as! Bool,
                       widget: (record as AnyObject).value(forKey: "widget") as! Bool)

    }
    
    func saveSetting(setting: Setting) {
        print("저장", setting.iter, setting.widget, setting.set1)
        print("widget 값", setting.iter.description(), setting.iter.rawValue)
        print(type(of: setting.iter.rawValue))
        if let context = context,
            let entity: NSEntityDescription
            = NSEntityDescription.entity(forEntityName: settingName, in: context) {
            
                let mysetting = NSManagedObject(entity: entity, insertInto: context)
                mysetting.setValue(setting.iter.rawValue, forKey: "iter")
                mysetting.setValue(setting.set1, forKey: "set1")
                mysetting.setValue(setting.widget, forKey: "widget")
            }
            
            do {
                try context?.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    
    func updateSetting(setting: Setting, idx: Int){
        print("update Setting!!")
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MySetting")
        var myresult = [NSManagedObject]()
        let records = try! context!.fetch(request)
        
        if let records = records as? [NSManagedObject] {
            myresult = records
               }
        
        myresult[idx].setValue(setting.iter.rawValue, forKeyPath: "iter")
//        myresult[idx].setValue(2, forKeyPath: "iter")

        myresult[idx].setValue(setting.set1, forKeyPath: "set1")
        myresult[idx].setValue(setting.widget, forKeyPath: "widget")

        do {
            try context?.save()
            
            
        } catch {
            context?.rollback()
            print(error.localizedDescription)
        }

    }
    func deleteSetting(idx: Int) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: settingName)
        let results = try! context?.fetch(request)
        context?.delete(results![idx] as! NSManagedObject)

        do {
            try context?.save()
        } catch {
            context?.rollback()
            print(error.localizedDescription)
        }

    }
}
extension CoreDataManager {
    fileprivate func filteredRequest(id: Int64) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
            = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id = %@", NSNumber(value: id))
        return fetchRequest
    }
    
    fileprivate func contextSave(onSuccess: ((Bool) -> Void)) {
        do {
            try context?.save()
            onSuccess(true)
        } catch let error as NSError {
            print("Could not save🥶: \(error), \(error.userInfo)")
            onSuccess(false)
        }
    }
    
    func getCount() -> Int{
        let request: NSFetchRequest<Entity> = Entity.fetchRequest()
        do {
            let count = try context!.count(for: request)
            return count
        } catch {
            print(error)
            return -1
        }
    }
    
    func sortbyDday()->Array<Entity>{
        let request: NSFetchRequest<Entity> = Entity.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Entity.dday) , ascending: true)
        request.sortDescriptors = [sort]
        do {
            print("sort")
            try context?.save()
            let record = try context?.fetch(request)
            print(type(of: record))

            record?.forEach{
                print($0.name)
            }
            return record!
        } catch {
            print("Cannot fetch Expenses")
            return []
        }
    }
    
}
