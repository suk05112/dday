//
//  ViewController.swift
//  Dday
//
//  Created by 한수진 on 2021/07/19.
//

import UIKit
import UserNotifications
import CoreData

class ViewController: UIViewController {

    var numberOfCell: Int = 0
    var cellIdentifier: String = "cell"
    var rcvIdx: IndexPath = [-1, -1]
    
    let dateFormatter = DdayDateFormatter.shared
    
    let delegate = UIApplication.shared.delegate as? AppDelegate

    let notification = DdayNotificationCenter()
    let didDismissPostCommentViewController: Notification.Name = Notification.Name("DidDismissPostCommentViewController")
    
    let item = Item()
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        print("view load")
//        CoreDataManager.shared.deleteAll()
        
        numberOfCell = CoreDataManager.shared.getCount()
        if rcvIdx.row != -1 {
            removeData(indexPath: rcvIdx)
        }

        collectionView.dataSource = self
        collectionView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.didDismissPostCommentNotification(_:)), name: didDismissPostCommentViewController, object: nil)
        
        WidgetUtility.save_widgetData()
        collectionView.reloadData()
    }

    @objc func didDismissPostCommentNotification(_ noti: Notification) {
        print("함수 안!!")
        collectionView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show" {
            delegate?.mode = "CREATE"
            let viewController: AddViewController = segue.destination as! AddViewController
                viewController.delegate = self
            
            print("seg show")
        }
        if segue.identifier == "GoToDetail"{
            let detail: DetailViewController = segue.destination as! DetailViewController
            print("detail show")
            if let cell = sender as? UICollectionViewCell,
               let indexPath = self.collectionView.indexPath(for: cell) {
                let (name, day, dday) = item.getItemData(idx: indexPath.row)

                detail.data = RecieveData(name: name, day: day, dday: Int(dday)!)
                detail.idx = getfilterdIndexByset1()[indexPath.row]

            }
        }
    }

    func add(data: RecieveData, setting: Setting, idx: Int) {
        item.add(data: data, setting: setting, idx: idx)
        notification.setNoticifation(idx: idx)
        self.numberOfCell += 1
    }
    
    func removeData(indexPath: IndexPath) {
        collectionView.deleteItems(at: [indexPath])

        item.delete(idx: indexPath.row)
        notification.removeNotification(idx: indexPath.row)

        self.numberOfCell -= 1
        rcvIdx = [-1, -1]

    }
}

extension ViewController: SendProtocol {
    func send(date: Date, name: String, setting: Setting, idx: Int) {

        let calculatedDday = CalculateDay.shared.calculateDday(selectDay: date, setting: setting)
        print("result 받은 직후", calculatedDday)

        add(data: RecieveData(name: name,
                          day: dateFormatter.string(from: date),
                          dday: calculatedDday),
            setting: setting, idx: idx)
    }
}

extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupID = "group.com.sujin.Dday"
        return UserDefaults(suiteName: appGroupID)!
    }
}
