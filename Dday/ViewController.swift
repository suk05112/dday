//
//  ViewController.swift
//  Dday
//
//  Created by 한수진 on 2021/07/19.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, SendProtocol {

    var dataList = [rcvData]()
    var numberOfCell: Int = 0
    var cellIdentifier: String = "cell"

    @IBOutlet weak var collectionView: UICollectionView!
    
    //지정된 섹션에 표시할 항목의 개수를 묻는 메서드
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { //2
        print("init")
        return self.numberOfCell
    }
    
    //컬렉션뷰의 지정된 위치에 표시할 셀을 요청하는 메서드
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? data else {
            print("else")
            return UICollectionViewCell()
        }

        print("set")
        print(dataList.count)
        print("idxrow")
        print(indexPath.row)
        if !dataList.isEmpty{
            cell.day.text = dataList[indexPath.row].day
            cell.name.text = dataList[indexPath.row].name
            cell.dday.text = String(dataList[indexPath.row].dday)
        }
        
        cell.contentView.isUserInteractionEnabled = true

        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)  {
        self.numberOfCell -= 1
        print("Cell \(indexPath.row + 1) clicked")
        print("idxpath", indexPath.row)
        dataList.remove(at: indexPath.row)
        print(dataList.count)

        collectionView.deleteItems(at: [indexPath])
        print("data remove!!")
        print("reload~~")
    }
    
    

    
   func cancelButtonAction(sender : UICollectionViewCell) {
        /* 컬랙션뷰의 데이터를 먼저 삭제 해주고, 데이터 배열의 값을 삭제해줍니다!! , '반대로할시에 데이터가 꼬이는 현상이 발생합니다.'*/
        collectionView.deleteItems(at: [IndexPath.init(row: sender.tag, section: 0)])
        dataList.remove(at: sender.tag)
    
   }

   func add(){
        print("add")
        self.numberOfCell += 1
        collectionView.reloadData()
    }

    override func viewDidLoad() { //1
        super.viewDidLoad()
        print("viewDidLoad")
        collectionView.dataSource = self
        collectionView.delegate = self

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //3
//        print("prepare")
            if segue.identifier == "show" {
                let viewController : Add = segue.destination as! Add
                    viewController.delegate = self
            }
        }
    
    func send(date: Date, name: String) { //5
        let formatter = DateFormatter()
        let result = calculateDday(d_day: date)

        formatter.dateFormat = "yyyy.MM.dd EEE"

//        print("rcvdate", date)
        dataList.append(rcvData(name: name, day: formatter.string(from: date), dday: result))
        add()
    }
    
    func calculateDday(d_day: Date) -> Int{
        let today = Date()
        guard let distanceSecond = Calendar.current.dateComponents([.hour], from: d_day, to: today).hour else { return 0 }
//        print("dist")
        print(distanceSecond/24)
        return (distanceSecond/24) - 1
    }
}

class rcvData {
    var name: String
    var day: String
    var dday: Int
    
    init(name: String, day: String, dday:Int){
        self.name = name
        self.day = day
        self.dday = dday
    }
}

class data: UICollectionViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var dday: UILabel!
}
