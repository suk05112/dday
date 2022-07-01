//
//  Detail.swift
//  Dday
//
//  Created by 한수진 on 2021/08/02.
//

import UIKit
import SnapKit

class DetailViewController: UIViewController {
//    @IBOutlet weak var detailName: UILabel!
//    @IBOutlet weak var detailDday: UILabel!
//    @IBOutlet weak var detailDay: UILabel!
//    @IBOutlet weak var iterSet: UILabel!
    
    var data: RecieveData = RecieveData.init(name: "init name", day: "init day", dday: 0)
    var idx: Int = -1
    let delegate = UIApplication.shared.delegate as? AppDelegate

    let didDismissPostCommentViewController: Notification.Name = Notification.Name("DidDismissPostCommentViewController")
    
    var detailView = DetailView()
    let item = Item()
    var (name, day, dday) = ("", "", "")
    var setting = Setting()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.view.addSubview(detailView)
        detailView.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view)
        }
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
        
        if UserDefaults.standard.bool(forKey: "hide") {
            for idx in 0..<numOfdata {
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
        
        detailView.detailName.text = name
        detailView.detailDay.text = day
        detailView.detailDday.text = item.getDdayString(dday: Int(dday)!, set1: setting.set1)
        detailView.iterSet.text = setting.iter.kor()
        
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

class DetailView: UIView {
    let view = UIView()
    let detailName: UILabel = {
        let label = UILabel()
        label.text = "name"
        label.font = UIFont.systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let detailDay: UILabel = {
        let label = UILabel()
        label.text = "day"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let detailDday: UILabel = {
        let label = UILabel()
        label.text = "dday"
        label.font = UIFont.systemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let iterSet: UILabel = {
        let label = UILabel()
        label.text = "iterSet"
        label.font = UIFont.systemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadView()
    }
    
    required init?(coder: NSCoder) {
       super.init(coder: coder)
//
    }
    
    private func loadView() {

        addSubview(detailName)
        addSubview(detailDay)
        addSubview(detailDday)
        addSubview(iterSet)

        detailName.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.bottom.equalTo(self.snp.centerY)
        }
        detailDay.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(detailName.snp.bottom)
        }
        detailDday.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(detailDay.snp.bottom)
        }
        iterSet.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(detailDday.snp.bottom)
        }
    }
 
    
    private func makeLabel(str: String) -> UILabel {
        let label = UILabel()
        label.text = str
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }
}
