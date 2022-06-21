//
//  CoreDataStack.swift
//  Dday
//
//  Created by 한수진 on 2021/08/29.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()

    private init() {}

    var managedObjectContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }

    var workingContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.managedObjectContext
        return context
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DdayModel")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
//                RaiseError.raise()
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        self.managedObjectContext.performAndWait {
            if self.managedObjectContext.hasChanges {
                do {
                    try self.managedObjectContext.save()
//                    appPrint("Main context saved")
                } catch {
                    print(error)
//                    RaiseError.raise()
                }
            }
        }
    }

    func saveWorkingContext(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("Working context saved")
            saveContext()
        } catch let error {
            print(error)
//            RaiseError.raise()
        }
    }
}
