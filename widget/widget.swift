//
//  widget.swift
//  widget
//
//  Created by 한수진 on 2021/08/24.
//

import WidgetKit
import SwiftUI
import Intents
import CoreData

struct Provider: IntentTimelineProvider {
//    var moc = PersistenceController.shared.managedObjectContext

    func placeholder(in context: Context) -> SimpleEntry {
        print("place holder")
        
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.sujin.Dday")!
        let storeURL = containerURL.appendingPathComponent("DdayModel.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)

        let container = NSPersistentContainer(name: "DdayModel")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
            
        }
        let moc = CoreDataStack.shared.managedObjectContext
        let request = NSFetchRequest<Entity>(entityName: "Entity")
        let results = try! moc.fetch(request)
        results.forEach{
            print($0)
        }
        print("end place holder")

        return SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        /*
        print("in snap")
        
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.sujin.Dday")!
        let storeURL = containerURL.appendingPathComponent("DdayModel.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)

        let container = NSPersistentContainer(name: "DdayModel")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
            
        }
        let context = CoreDataStack.shared.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        let results = try! context.fetch(request)
        results.forEach{
            print($0)
        }
        print("end in snap")
        */

//        let moc = CoreDataStack.shared.managedObjectContext

//        let predicate = NSPredicate(format: "name == %@", "name")
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
//        let results = try! container.fetch(request)
//        let request = NSFetchRequest<Entity>(entityName: "Entity")
//        let result = try! moc.fetch(request)


        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        /*
        print("in timeline")

        
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.sujin.Dday")!
        let storeURL = containerURL.appendingPathComponent("DdayModel.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)

        let container = NSPersistentContainer(name: "DdayModel")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
            
        }
        let moc = CoreDataStack.shared.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        let results = try! moc.fetch(request)
        results.forEach{
            print($0)
        }
        print("end in timeline")
*/
//        let record = yourResult![0]
//
//        print(record.value(forKey: "day") ?? -1)
//        print(record.value(forKey: "name") ?? -1)
//        print(record.value(forKey: "dday") ?? -1)
/*
         
        request.predicate = NSPredicate(format: "attribute1 == %@", "test")
                do {
                    yourResult = try context.fetch(request) as? [Entity]
                    completion(yourResult)
                } catch let error as NSError{
                    print(error.localizedDescription)
                }
        */
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct widgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

@main
struct widget: Widget { //위젯 추가하는 화면
    let kind: String = "widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            widgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct widget_Previews: PreviewProvider {
    
    
    static var previews: some View {
        widgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
    
    static let sharedDataFileURL: URL = {
           let appGroupIdentifier = "group.com.sujin.Dday"
           if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
               return url.appendingPathComponent("Plants.plist")
           }
           else {
               preconditionFailure("Expected a valid app group container")
           }
       }()
}
