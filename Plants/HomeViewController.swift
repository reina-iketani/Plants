//
//  HomeViewController.swift
//  Plants
//
//  Created by Reina Iketani on 2023/06/20.
//

import UIKit
import RealmSwift
import UserNotifications 


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var taskLvel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLavel: UILabel!
    
    
    lazy var realm = try! Realm()
    var taskArray:[String] = []
    var notificationToken: NotificationToken?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
            notificationToken = realm.observe { [weak self] (notification, realm) in

                self?.generateTaskArray() // Realmデータが変更されたらtaskArrayを再生成
                self?.tableView.reloadData() // tableViewを更新
                self?.taskLvel.text = "今日のタスク：" + String(self?.taskArray.count ?? 0) + "件" // タスクの数を更新
                
            }
        
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        let nib = UINib(nibName: "TaskHomeTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        generateTaskArray()
        tableView.reloadData()
        
        self.taskLvel.text = "今日のタスク：" + String(taskArray.count) + "件"
        
        
        // 通知の許可を要求
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                if let error = error {
                    // エラーハンドリング
                    print("通知の許可リクエストでエラーが発生しました: \(error.localizedDescription)")
                } 
            }
        
        imageView.image = UIImage(named: "monstera")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        tableView.reloadData()
        
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TaskHomeTableViewCell
        //cell.setData()
        let task = taskArray[indexPath.row]
        cell.lavel.text = task
        cell.lavel.textAlignment = .left
        print("task",task)
        if task.contains("に水やりの日です") {
            print("表示")
            cell.button.isHidden = false
            cell.button.addTarget(self, action: #selector(handleButton(_:forEvent:)), for: .touchUpInside)
            createNotification(title: "タスクの通知", body: task)
        
        } else {
            
            cell.button.isHidden = true
            //cell.button.removeTarget(self, action: #selector(handleButton(_:forEvent:)), for: .touchUpInside)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    

    
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
            

        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        
        let task = taskArray[indexPath!.row]
        
        // タスクの削除処理
        let elementToRemove = task
        if let index = taskArray.firstIndex(of: elementToRemove) {
            taskArray.remove(at: index)
        }
        //アラートから削除
        deleteNotification(withIdentifier: task)
            
        //let del: set<Character> = ["に水やりの日です"]
        let name = task.replacingOccurrences(of: "に水やりの日です", with: "")
        
        print("name",name)
            let plants = realm.objects(Myplants.self).filter("name = %@", name)
            if let plant = plants.first {
                
//                let center = UNUserNotificationCenter.current()
//                center.removePendingNotificationRequests(withIdentifiers: [String(task)])
                
                // waterLastdateを今日の日付に更新
                try! realm.write {
                    print("update")
                    plant.waterLastdate = Date()
                    //realm.add(plant)
                    realm.add(plant, update: .modified)
                }
                tableView.reloadData()
                
            }
        
        
        
        let button = sender
        button.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
       
        
            
    }
    
    func deleteNotification(withIdentifier identifier: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    
    
    
    func generateTaskArray() {
        taskArray.removeAll()
        let currentDate = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M"
        let currentMonth = Int(dateFormatter.string(from: currentDate)) ?? 0
        
        dateFormatter.dateFormat = "dd"
        let today = Int(dateFormatter.string(from: currentDate)) ?? 0

        let informations = realm.objects(Information.self)
        let plants = realm.objects(Myplants.self)

        if currentMonth >= 5 && currentMonth <= 10 {
            // 5月から10月のタスク
           
            //self.lavel.text = "5月から10月は鉢変えにおすすめの時期です。"
            taskArray.append("5月から10月は鉢変えにおすすめの時期です")

            for plant in plants {
                for information in informations {
                    if plant.plants == information.plants {
                        if let ssWaterDate = Calendar.current.date(byAdding: .day, value: Int(information.sswater) ?? 0, to: plant.waterLastdate),
                           let currentDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: currentDate) {
                            
                            if ssWaterDate <= currentDate {
                                taskArray.append("\(plant.name)に水やりの日です")
                            }
                        }
                    }
                }
            }
            
        } else  {
            // 11月から4月のタスク
            
            taskArray.append("11月から4月は断水時期です。いつもより水やりの間隔を空けましょう。")

            for plant in plants {
                for information in informations {
                    if plant.plants == information.plants {
                        if let awWaterDate = Calendar.current.date(byAdding: .day, value: Int(information.awwater) ?? 0, to: plant.waterLastdate),
                           let currentDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: currentDate) {
                            if awWaterDate <= currentDate {
                                taskArray.append("\(plant.name)に水やりの日です。")
                            }
                        }
                    }
                }
            }
        }

        let threeMonthAgo = Calendar.current.date(byAdding: .month, value: -3, to: currentDate)!
        let diaries = realm.objects(Diary.self).filter("date >= %@", threeMonthAgo)

        if diaries.isEmpty {
            taskArray.append("成長記録を残しませんか？")
        }
        
        let myplants = realm.objects(Myplants.self)
        if myplants .isEmpty {
            taskArray.append("MY植物を登録しましょう")
        }
        
        if today % 3 == 0 {
            taskArray.append("２、3日に１度は日光浴をさせましょう")
        }
        
    }
    
    func createNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        // 通知のトリガーを作成（5秒後に通知を表示する）
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // 通知のリクエストを作成
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // 通知をスケジュール
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                // エラーハンドリング
                print("通知のスケジュールでエラーが発生しました: \(error.localizedDescription)")
            }
        }
        // ローカル通知を登録
                let center = UNUserNotificationCenter.current()
                center.add(request) { (error) in
                    print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
                }

                // 未通知のローカル通知一覧をログ出力
                center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                    for request in requests {
                        print("/---------------")
                        print(request)
                        print("---------------/")
                    }
                }
    }

    deinit {
            // 通知の解除
            notificationToken?.invalidate()
        }

}
