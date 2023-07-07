//
//  MyplantsViewController.swift
//  Plants
//
//  Created by Reina Iketani on 2023/06/20.
//

import UIKit
import RealmSwift
import Foundation

class MyplantsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    lazy var realm = try! Realm()
    var plantsArray: Results<Myplants>!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        
        let nib = UINib(nibName: "MyplantsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        imageView.image = UIImage(named: "monstera")
        
        plantsArray = realm.objects(Myplants.self).sorted(byKeyPath: "id", ascending: true)
        
        
    }
    
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plantsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyplantsTableViewCell
                cell.setData(plantsArray[indexPath.row])
        
        return cell
        
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "cellSegue",sender: nil)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
            if segue.identifier == "cellSegue" {
                let detailViewController:DetailViewController = segue.destination as! DetailViewController
                let indexPath = self.tableView.indexPathForSelectedRow
                detailViewController.myplants = plantsArray[indexPath!.row]
            }
        }


    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        super.viewWillAppear(animated)
        if plantsArray.count == 0 {
            tableView.isHidden = true
            emptyView.isHidden = false
        } else {
            tableView.isHidden = false
            emptyView.isHidden = true
        }
        
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let plant = plantsArray[indexPath.row]
            let alert = UIAlertController(title: "削除", message: "\(plant.name)を削除します。\(plant.name)の成長記録も削除されてしまいます。よろしいですか？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in
                    self.deletePlant(at: indexPath)
                print("preperdelete")
                }))//alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
            
        }
    }
    
    
    
   
    
    func deletePlant(at indexPath: IndexPath) {
        let plant = plantsArray[indexPath.row]
        let diaryArray = realm.objects(Diary.self).filter("name == %@", plant.name)
            try! realm.write {
                print("delete")
                realm.delete(diaryArray)
                self.realm.delete(self.plantsArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            }
            
        
        
    }
    
}
