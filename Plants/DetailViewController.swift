//
//  DetailViewController.swift
//  Plants
//
//  Created by Reina Iketani on 2023/06/23.
//

import UIKit
import RealmSwift
import CLImageEditor

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLImageEditorDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lavel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLavel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    
    
    lazy var realm = try! Realm()
    var myplants: Myplants!
    //var diaries: Results<Diary>!
    var diaries = try! Realm().objects(Diary.self).sorted(byKeyPath: "date", ascending: true)
    var image: UIImage!
    var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.textField.text = myplants.name
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        let dateString:String = formatter.string(from: myplants.waterLastdate)
        self.lavel.text = "最終水やり日:" + dateString
        
        
        self.button.setTitle(myplants.plants + "の説明", for: .normal)
        
        
        

        if let image = image {
            imageView.image = image
            
        } else if let imageName = myplants.image,
            let imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(imageName),
            let imageData = try? Data(contentsOf: imageURL) {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: imageData)
                }
        } else {
            self.imageView.image = UIImage(named: "no_image")
        }
        
        let tapGuesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dissmissKeyboard))
        view.addGestureRecognizer(tapGuesture)
        
        tableView.dataSource = self
        tableView.delegate = self
        let nib = UINib(nibName: "AddDiaryTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        diaries = realm.objects(Diary.self).filter("name = %@", myplants.name).sorted(byKeyPath: "date", ascending: false)
        //tableView.reloadData()
        let notificationToken = diaries.observe { [weak self] _ in
                    self?.tableView.reloadData()
                }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        if diaries.count == 0 {
            tableView.isHidden = true
            emptyView.isHidden = false
        } else {
            tableView.isHidden = false
            emptyView.isHidden = true
        }
        
        tableView.reloadData()
        
    }
    
    
    @IBAction func diaryButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let diaryView = storyboard.instantiateViewController(withIdentifier: "DiaryViewController") as? DiaryViewController {
            diaryView.plantsName = myplants.name
            present(diaryView, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let searchResultViewController = segue.destination as? SearchResultViewController {
            searchResultViewController.plants = myplants.plants
        }
            
    }
    
    
    @IBAction func cameraButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func libraryButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // UIImagePickerController画面を閉じる
            picker.dismiss(animated: true, completion: nil)
            // 画像加工処理
            if info[.originalImage] != nil {
                // 撮影/選択された画像を取得する
                let image = info[.originalImage] as! UIImage
                // あとでCLImageEditorライブラリで加工する
                print("DEBUG_PRINT: image = \(image)")
                let editor = CLImageEditor(image: image)!
                editor.delegate = self
                self.present(editor, animated: true, completion: nil)
            }
    }
    
    //加工終了時に呼び出す
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        //addmyplants画面に戻る
        
        self.image = image
        editor.dismiss(animated: true, completion: nil)

        DispatchQueue.main.async {
            self.imageView.image = self.image
        }
        
        

    }
    
    // CLImageEditorの編集がキャンセルされた時に呼ばれるメソッド
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        // CLImageEditor画面を閉じる
        editor.dismiss(animated: true, completion: nil)
    }
    
    //戻ったら更新する
    override func viewWillDisappear(_ animated: Bool) {
        saveImage()
        try! realm.write {
            self.myplants.name = self.textField.text!
            self.myplants.image = documentDirectoryFileURL.lastPathComponent
            self.realm.add(self.myplants, update: .modified)
        }
        super.viewWillDisappear(animated)
    }
    
    //保存するためのパスを作成する
    func createLocalDataFile() -> String {
        // 作成するテキストファイルの名前
        let fileName = "\(NSUUID().uuidString).png"
        let path = documentDirectoryFileURL.appendingPathComponent(fileName).path
        return path
        
    }
    
    var documentDirectoryFilePath: String = ""
    func saveImage() {
        
        let filePath = createLocalDataFile()
        if let pngImageData = imageView.image?.pngData() {
            do {
                let fileURL = URL(fileURLWithPath: filePath)
                try pngImageData.write(to: fileURL)
                documentDirectoryFileURL = fileURL
            } catch {
                //エラー処理
                print("エラー")
            }
        }
    }
    

    @objc func dissmissKeyboard() {
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AddDiaryTableViewCell
        let diary = diaries[indexPath.row]
        cell.setData(diary)
        return cell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let diary = diaries[indexPath.row]
            let alert = UIAlertController(title: "削除", message: "\(diary.comment)を削除します。よろしいですか？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in
                    self.deleteDiary(at: indexPath)
                print("preperdelete")
                }))//alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func deleteDiary(at indexPath: IndexPath) {
            
        try! realm.write {
            self.realm.delete(self.diaries[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }

}
