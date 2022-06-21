//
//  Detail.swift
//  Dday
//
//  Created by 한수진 on 2021/08/02.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var detailName: UILabel!
    @IBOutlet weak var detailDday: UILabel!
    @IBOutlet weak var detailDay: UILabel!
    @IBOutlet weak var iterSet: UILabel!
    
    var data: RecieveData = RecieveData.init(name: "init name", day: "init day", dday: 0)
    var idx: Int = -1
    let delegate = UIApplication.shared.delegate as? AppDelegate

    let didDismissPostCommentViewController: Notification.Name = Notification.Name("DidDismissPostCommentViewController")
    
    let item = Item()
    var (name, day, dday) = ("", "", "")
    var setting = Setting()

    override func viewDidLoad() {
        super.viewDidLoad()
        (name, day, dday) = item.getItemData(idx: self.idx)
        setting = item.getItemSetting(idx: idx)

        loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didDismissPostCommentNotification(_:)), name: didDismissPostCommentViewController, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: didDismissPostCommentViewController, object: nil, userInfo: nil)
    }
    
    @objc func didDismissPostCommentNotification(_ noti: Notification) {
        print("dismiss")
        loadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit" {
            print("edit show")
            guard let viewController: AddViewController = segue.destination as? AddViewController else {return}
        }

    }
    
    func getfilterdIndexByset1() -> [Int] {
        let numOfdata = CoreDataManager.shared.getCount()
        var filteredIdx: [Int] = []
        
        if(UserDefaults.standard.bool(forKey: "hide")){
            for idx in 0..<numOfdata{
                if setting.set1 || Int(dday)! < 1 {
                    filteredIdx.append(idx)
                }
            }
        } else {
            filteredIdx = Array(0..<numOfdata)
        }

        return filteredIdx
    }

    func loadData() {
        (name, day, dday) = item.getItemData(idx: self.idx)
        setting = item.getItemSetting(idx: idx)
        
        self.detailName.text = name
        self.detailDay.text = day
        self.detailDday.text = item.getDdayString(dday: Int(dday)!, set1: setting.set1)
        self.iterSet.text = setting.iter.kor()
        
    }
    
    @IBAction func edit(_ sender: Any) {

        delegate?.mode = "UPDATE"
        delegate?.updateIdx = self.idx
        let viewControllerName = self.storyboard?.instantiateViewController(withIdentifier: "edit")
        viewControllerName?.modalTransitionStyle = .flipHorizontal
        if let view = viewControllerName {
            self.present(view, animated: true, completion: nil)
        }
    }
    
    @IBAction func remove(_ sender: Any) {
        print("remove")
        let alert = UIAlertController(title: "알림", message: "삭제하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "네", style: .default) { (action) in
            let mainVC = self.presentingViewController
            guard let vc = mainVC as? ViewController else { return }
            vc.rcvIdx = IndexPath(row: self.idx, section: 0)
            
            self.dismiss(animated: true) {
                print("dismiss")
                vc.viewDidLoad()
            }
        }
        
        let noAction = UIAlertAction(title: "아니요", style: .default) { (action) in
            }
        alert.addAction(okAction)
        alert.addAction(noAction)
        present(alert, animated: false, completion: nil)

    }

}
