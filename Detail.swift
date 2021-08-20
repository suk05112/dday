//
//  Detail.swift
//  Dday
//
//  Created by 한수진 on 2021/08/02.
//

import UIKit

class Detail: UIViewController {
    
    @IBOutlet weak var detail_name: UILabel!
    @IBOutlet weak var detail_dday: UILabel!
    
    var data: rcvData = rcvData.init(name: "init name", day: "init day", dday: 0)
    var idx:IndexPath = [-1, -1]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.detail_name.text = data.name
        self.detail_dday.text = String(data.dday)
        print("detail idx=", idx)
    }

    @IBAction func edit(_ sender: Any) {
          self.presentingViewController?.dismiss(animated: true)
      }
    
    @IBAction func remove(_ sender: Any){
        let alert = UIAlertController(title: "알림", message: "삭제하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
       
        let okAction = UIAlertAction(title: "네", style: .default) { (action) in
            print("say yes")
            let mainVC = self.presentingViewController
            guard let vc = mainVC as? ViewController else {return}
            vc.rcvIdx = self.idx
            self.dismiss(animated: true) {
                print("dismiss")
                vc.viewDidLoad()
                    }
//            self.presentingViewController?.dismiss(animated: true)
        }
        
        let noAction = UIAlertAction(title: "아니요", style: .default) { (action) in
            }
        
        alert.addAction(okAction)
        alert.addAction(noAction)

        present(alert, animated: false, completion: nil)
//        self.presentingViewController?.dismiss(animated: true)

        
    }

    func sendDetailData(data: rcvData, idx: IndexPath) {
        self.data = data
        self.idx = idx
        print("data=",data)
    }

}

