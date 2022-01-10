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

        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {

        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        
        let year = Calendar.current.dateComponents([.year], from: currentDate).year
        let month = Calendar.current.dateComponents([.month], from: currentDate).month
        let day = Calendar.current.dateComponents([.day], from: currentDate).day
        
        let dateComponents = DateComponents(year: year, month: month, day: day, hour: 0, minute: 0)
        let refreshDate = Calendar.current.date(from: dateComponents)!

        let entry = SimpleEntry(date: currentDate, configuration: configuration)
        entries.append(entry)


        let timeline = Timeline(entries: entries, policy: .after(refreshDate))
//        let timeline = Timeline(entries: entries, policy: .never)
//        let timeline = Timeline(entries: entries, policy: .atEnd(refreshDate))


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
    print("in getwidgetData", i)
    
    if i<data.count{
        return data[i].name
    }
    else{
        return ""
    }
    
    
    let date = Date()
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "mm" // 2020-08-13 16:30
            
            
    let myDateFormatter = DateFormatter()
    
    myDateFormatter.dateFormat = "yyyy년 MM월 dd일 a hh시 mm분" // 2020년 08월 13일 오후 04시 30분
    myDateFormatter.locale = Locale(identifier:"ko_KR") // PM, AM을 언어에 맞게 setting (ex: PM -> 오후)
    
    let convertStr = myDateFormatter.string(from: date)
    
    return convertStr
}
func getDayOfWidgetData(data:[WidgetData], i:Int) -> String{
    print("in getwidgetData", i)
   

    if i<data.count{
        
        let dday = data[i].dday
        let set1 = getUserdata()[i].set1
        
        if(set1){
            if (Int(dday)!<0){
                return "D-" + String(abs(Int(dday)!))
            }
            else{
                return String(dday) + "일"

            }

        }
        else{
            if (Int(dday)!<0){
                return "D" + String(dday)
            }
            else if(Int(dday) == 0){
                return"D-day"
            }
            else{
                return "D+" + String(dday)

            }
        }
        
    }

    else{
        return " "
    }

}

func getImage(name: String, type: String = "png") -> UIImage? {
        guard let plugins = Bundle.main.builtInPlugInsPath,
              let bundle = Bundle(url: URL(fileURLWithPath:
                           plugins).appendingPathComponent("sujin.Dday.widget")),
              let path = bundle.path(forResource: name, ofType: type)
              else { return nil }
        return UIImage(contentsOfFile: path)
    }

struct widgetEntryView : View {
    var entry: Provider.Entry
    var myData = DataEntry(date: Date(), widget_data: getUserdata())
    
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var scheme

    
    var maxCount: Int {
        switch family {
        case .systemMedium:
            return 3
        case .systemLarge:
            return min(getUserdata().count, 7)
        default:
            return min(getUserdata().count, 5)
        }
    }


    var body: some View {
        
        ZStack{
            Theme.myBackgroundColor(forScheme: scheme)

            Color(red: CGFloat(250)/255.0, green: CGFloat(205)/255.0, blue: CGFloat(205)/255.0, opacity: 0.4).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50, alignment: .leading)

            HStack{
                Image("postit")
                    .resizable()
                    .frame(width: 20, height: 20, alignment: .center)
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 0))

                
                Text("Post Day")
                    .font(.system(size: 15, weight: .semibold ))
                    .foregroundColor(.black)
                    .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                    .frame(alignment: .leading)
                
                Spacer()

            }

        }
        
        VStack{
            Theme.myBackgroundColor(forScheme: scheme)

            ForEach(0..<maxCount) { index in
                HStack{
                    Text(getWidgetData(data:getUserdata(), i:index))
                        .font(.system(size: 15))
//                        .foregroundColor(.black)
                        .frame(alignment: .leading)
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        .foregroundColor(scheme == .light ? .black : .white)


                    Spacer()
                    
                    Text(getDayOfWidgetData(data:getUserdata(), i:index))
                        .font(.system(size: 15, weight: .semibold))
//                        .foregroundColor(.black)
                        .frame(alignment: .center)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                        .foregroundColor(scheme == .light ? .black : .white)

                }

                Divider()

            }
            .frame(alignment: .center)

            Spacer()

        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))

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

struct Theme {
    static func myBackgroundColor(forScheme scheme: ColorScheme) -> Color {
        let lightColor = Color.white
        let darckColor = Color.black
        
        switch scheme {
        case .light : return lightColor
        case .dark : return darckColor
        @unknown default: return lightColor
        }
    }
}
