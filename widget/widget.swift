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

}
func getDayOfWidgetData(data:[WidgetData], i:Int) -> String{
    print("in getwidgetData")
    return data[i].dday

}

struct widgetEntryView : View {
    var entry: Provider.Entry
    var myData = DataEntry(date: Date(), widget_data: getUserdata())
    
    @Environment(\.widgetFamily) var family
        
        var maxCount: Int {
            switch family {
            case .systemMedium:
                return 1
            default:
                return 5
            }
        }
    
    var body: some View {
        
        ZStack{
            Color.green.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50, alignment: .leading).opacity(0.4)

            HStack{
                Text("디데이 위젯")
                    .font(.system(size: 25, weight: .regular))
                    .foregroundColor(.black)
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 0))
                    .frame(alignment: .leading)
                
                Spacer()

            }

        }
//        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 40, alignment: .leading)
//        .background(Color.green, opacity(0.8))
//        .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
        
        VStack{

            ForEach(0..<3) { index in
                HStack{
                    Text(getWidgetData(data:getUserdata(), i:index))
                        .font(.body)
                        .foregroundColor(.black)
                        .frame(alignment: .leading)

                    Spacer()
                    
                    Text(getDayOfWidgetData(data:getUserdata(), i:index))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(alignment: .center)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 25))
                    

                }

                Divider()

            }
            .frame(alignment: .center)

            Spacer()

        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 3, trailing: 0))

//        .frame(height: 20)
//        .background(Color.blue)


    }
}

struct DdayView : View {
    var myData = DataEntry(date: Date(), widget_data: getUserdata())
    
    var body: some View {
        VStack(alignment: .leading){
            ForEach(0..<getUserdata().count) { index in
                Text(getDayOfWidgetData(data:getUserdata(), i:index))
                Text("dday view")
                Divider()
            }.frame(height: 20)
            
        }
    }
}
func getUserdata() -> [WidgetData]{
    guard let orderData = UserDefaults.shared.data(forKey: "data") else { return [] }
    print("widget data", try!JSONDecoder().decode([WidgetData].self, from: orderData))
    
    return try!JSONDecoder().decode([WidgetData].self, from: orderData)

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
        .configurationDisplayName("디데이 위젯")
        .description("위젯표시를 설정한 디데이들을 확인할 수 있습니다.")
        .supportedFamilies([.systemMedium, .systemLarge])
        
    }
    
}

struct widget_Previews: PreviewProvider {

    @Environment(\.widgetFamily) var family
        
    var maxCount: Int {
        switch family {
        case .systemMedium:
            return 3
        default:
            return 5
        }
    }
    
    static var previews: some View {
        
        Group{
            widgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .environment(\.sizeCategory, .medium)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            DdayView()
                .environment(\.sizeCategory, .medium)
                .previewContext(WidgetPreviewContext(family: .systemSmall))

        }


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
