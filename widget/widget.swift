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

    func placeholder(in context: Context) -> SimpleEntry {

        return SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        getUserdata()

        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {

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

struct Data: Identifiable{
    var id: String = "1"
    let data: WidgetData
    
}

struct DataEntry: TimelineEntry {
    var date: Date
    let widget_data : [WidgetData]
}

func getWidgetData(data:[WidgetData], i:Int) -> String{
    print("in getwidgetData")
    return data[i].name
//    myData.widget_data.forEach{
//        Text($0.name)
//        Divider()
//    }
    
}

struct widgetEntryView : View {
    var entry: Provider.Entry
    var myData = DataEntry(date: Date(), widget_data: getUserdata())
    
    var body: some View {
        VStack{
            ForEach(0..<getUserdata().count) { index in
                Text(getWidgetData(data:getUserdata(), i:index))
                Divider()
            }
            
        }
//        Text(UserDefaults.shared.string(forKey: "test")!)
//        print(UserDefaults.standard.string(forKey: "test")!)
    }
}

func getUserdata() -> [WidgetData]{
    print("in getUser")
    guard let orderData = UserDefaults.shared.data(forKey: "data") else { return [] }
    print("widget data", try!JSONDecoder().decode([WidgetData].self, from: orderData))
    return try!JSONDecoder().decode([WidgetData].self, from: orderData)
    /*
    if let data1 = UserDefaults.standard.object(forKey: "data") as? Data{
        if let decode = try? JSONDecoder().decode([WidgetData].self, from: data1){
            return decode

        }
    }
*/
//    else { return [WidgetData(name: "", dday: "")] }
//    return decode
}

func getCoredata(){
    let storeURL = AppGroup.facts.containerURL.appendingPathComponent("Dday.sqlite")
    let description = NSPersistentStoreDescription(url: storeURL)

    let container = NSPersistentContainer(name: "Dday")
    container.persistentStoreDescriptions = [description]
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

extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupId = "group.com.sujin.Dday"
        return UserDefaults(suiteName: appGroupId)!
    }
}
