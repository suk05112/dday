//
//  AppDelegate.swift
//  Dday
//
//  Created by 한수진 on 2021/07/19.
//

import UIKit
import CoreData
import UserNotifications
import BackgroundTasks


extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let noticenter = DdayNotificationCenter()
        
        noticenter.ringAlarm(idx: 0, today: true)
        print("백그라운드에서 실행됨")
        
        completionHandler()
        

        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent noti: UNNotification,
                                withCompletionHandler completionHandler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = noti.request.content.userInfo
        print(userInfo)
        print("앱 실행 중")
        
        completionHandler([.list, .banner])
        
    }
    
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var mode: String?
    var updateIdx: Int!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("did finish launching")
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self
        if (launchOptions?[.remoteNotification]) != nil {
                print("앱 종료됨")
            }
        /*
        BGTaskScheduler.shared.register(
                    forTaskWithIdentifier: "com.example.apple-samplecode.ColorFeed.refresh",
                    using: nil) { task in
                    self.handleAppRefresh(task as! BGAppRefreshTask)
                    }
        
        BGTaskScheduler.shared.register(
                    forTaskWithIdentifier: "com.example.apple-samplecode.ColorFeed.db_cleaning",
                    using: nil) { task in
                    self.handleAppRefresh(task as! BGAppRefreshTask)
                    }
                
        */
        return true
        
    }
/*
    private func handleAppRefresh(_ task: BGAppRefreshTask) {
        scheduleAppRefresh()
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let operations = Operations.getOperationsToFetchLatestEntries(using: context, server: server)
        let lastOperation = operations.last!
        
        //때에 따라서는 너무 오래걸린다던가 해서 종료될 때가 있죠. 그 때를 위한 정리 핸들러에요.
        task.expirationHandler = { //예제에서는 OperationQueue를 사용하니까, 모든 동작을 취소했네요.
            queue.cancelAllOperations()
            
        } //이 부분은 Alamofire의 api ressponse 처리 블록 등이 될 수 있겠죠? 예제에서는 Operation Queue를 사용했네요.
        lastOperation.completionBlock = { //작업 완료 시, setTaskCompleted를 반드시 호출해주세요. 동기로 호출될 필요는 없어요!
            task.setTaskCompleted(success: !lastOperation.isCancelled)
            
        }
        queue.addOperations(operations, waitUntilFinished: false)


        
    }
 */
    
    /*
    //BGProcessingTask에서 수행할 것을 구현합니다. 위와 똑같아요!

    func handleDatabaseCleaning(task: BGProcessingTask) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        let context = NSPersistentContainer.newBackgroundContext()
        let predicate = NSPredicate(format: "timestamp < %@", NSDate(timeIntervalSinceNow: -24 * 60 * 60))
        let cleanDatabaseOperation = DeleteFeedEntriesOperation(context: context, predicate: predicate)
        
        task.expirationHandler = {
            // After all operations are cancelled, the completion block below is called to set the task to complete.
            queue.cancelAllOperations()
        }

        cleanDatabaseOperation.completionBlock = {
            let success = !cleanDatabaseOperation.isCancelled
            if success {
                // Update the last clean date to the current time.
                PersistentContainer.shared.lastCleaned = Date()
            }
            
            task.setTaskCompleted(success: success)
        }
        
        queue.addOperation(cleanDatabaseOperation)
    }

    */

    
    private func scheduleAppRefresh() {
            do {
                let request = BGAppRefreshTaskRequest(identifier: "pl.snowdog.example.refresh")
                request.earliestBeginDate = Date(timeIntervalSinceNow: 3600)
                try BGTaskScheduler.shared.submit(request)
            } catch {
                print(error)
            }
        }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
            scheduleAppRefresh()
        }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */

        let container = NSPersistentContainer(name: "DdayModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    func applicationWillResignActive(_ application: UIApplication) {
        print("홈버튼 누름")
    }
    

}


extension UIViewController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
            action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
