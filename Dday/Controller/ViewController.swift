//
//  ViewController.swift
//  Dday
//
//  Created by 한수진 on 2021/07/19.
//

import UIKit
import SwiftUI
import UserNotifications
import CoreData
import SnapKit

private let reuseIdentifier = "Cell"

//class ViewController: UICollectionViewController {
class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var numberOfCell: Int = 0
    var cellIdentifier: String = "cell"
    var rcvIdx: IndexPath = [-1, -1]
    
    let dateFormatter = DdayDateFormatter.shared
    
    let delegate = UIApplication.shared.delegate as? AppDelegate

    let notification = DdayNotificationCenter()
    let didDismissPostCommentViewController: Notification.Name = Notification.Name("DidDismissPostCommentViewController")
    
    let item = Item()
    var collectionView: UICollectionView?

    lazy var button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(pushNavi), for: .touchUpInside)
        return button
       }()

    lazy var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(goToAdd), for: .touchUpInside)
        return button
       }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()

        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white

        self.view.addSubview(button)
        self.view.addSubview(addButton)
        self.view.addSubview(collectionView!)
        
        button.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.leftMargin)
        }
        
        addButton.snp.makeConstraints { make in
//            make.center.equalTo(view.snp.center)
            make.top.equalTo(view.snp.topMargin)
            make.right.equalTo(view.snp.rightMargin)
        }
        
        collectionView?.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 100, left: 10, bottom: 20, right: 10))
            make.top.equalTo(button.snp.bottom)
        }
//        CoreDataManager.shared.deleteAll()
        
        numberOfCell = CoreDataManager.shared.getCount()
        if rcvIdx.row != -1 {
            removeData(indexPath: rcvIdx)
        }

        /*
        NotificationCenter.default.addObserver(self, selector: #selector(self.didDismissPostCommentNotification(_:)), name: didDismissPostCommentViewController, object: nil)
        
        WidgetUtility.save_widgetData()
        collectionView.reloadData()
        */
        print("view load")

    }
    
    fileprivate func setupCollectionView() {
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height), collectionViewLayout: UICollectionViewFlowLayout())
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
//        collectionView?.backgroundColor = .blue
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.register(CollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    @objc private func pushNavi() {
        let vc = ScreenSetting()
        
//        vc.modalPresentationStyle = .formSheet
        self.present(vc, animated: true, completion: nil)
    }

    @objc private func goToAdd() {
        let addVC = AddViewController()
    
//        vc.modalPresentationStyle = .formSheet
        self.present(addVC, animated: true, completion: nil)
    }
    
    @objc func didDismissPostCommentNotification(_ noti: Notification) {
        print("함수 안!!")
        collectionView?.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show" {
            delegate?.mode = "CREATE"
            let viewController: AddViewController = segue.destination as! AddViewController
                viewController.delegate = self
            
            print("seg show")
        }
    }

    func add(data: RecieveData, setting: Setting, idx: Int) {
        item.add(data: data, setting: setting, idx: idx)
        notification.setNoticifation(idx: idx)
        self.numberOfCell += 1
    }
    
    func removeData(indexPath: IndexPath) {
        collectionView?.deleteItems(at: [indexPath])

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

struct PreView: PreviewProvider {
    static var previews: some View {
        ViewController().toPreview()
    }
}

#if DEBUG
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
            let viewController: UIViewController

            func makeUIViewController(context: Context) -> UIViewController {
                return viewController
            }

            func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            }
        }

        func toPreview() -> some View {
            Preview(viewController: self)
        }
}
#endif

class CollectionViewCell: UICollectionViewCell {
    
    let name: UILabel = {
        let label = UILabel()
        label.text = "name"
        label.font = UIFont.systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let day: UILabel = {
        let label = UILabel()
        label.text = "day"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dday: UILabel = {
        let label = UILabel()
        label.text = "dday"
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
//       loadView()
   }

    private func loadView() {

        addSubview(name)
        addSubview(day)
        addSubview(dday)
        
        name.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.centerY)
            make.left.equalTo(self.snp.leftMargin)
        }
        day.snp.makeConstraints { make in
            make.top.equalTo(self.snp.centerY)
            make.left.equalTo(self.snp.leftMargin)
        }
        dday.snp.makeConstraints { make in
//            make.top.equalTo(day.snp.bottom)
            make.centerY.equalTo(self.snp.centerY)
            make.right.equalTo(self.snp.rightMargin)
        }
    }
    
    private func makeView() -> UIView {
        let view = UIView()
        view.backgroundColor = .purple
        return view
    }
    
    private func makeLabel(str: String) -> UILabel {
        let label = UILabel()
        label.text = str
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }

}
