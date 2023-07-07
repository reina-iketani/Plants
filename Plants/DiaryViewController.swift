//
//  DiaryViewController.swift
//  Plants
//
//  Created by Reina Iketani on 2023/06/23.
//

import UIKit
import RealmSwift
import CLImageEditor

class DiaryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate {
    
    @IBOutlet weak var lavel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    
    lazy var realm = try! Realm()
    var diary: Diary! = Diary()
    var plantsName: String = ""
    
    var image: UIImage!
    var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.lavel.text = plantsName
        
    
        if let image = image {
            imageView.image = image
        } else{
            imageView.image = UIImage(named: "no_image")
        }
        
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.borderColor =  UIColor.gray.cgColor
        
    }
    
    
    
    
    @IBAction func postButton(_ sender: UIButton) {
        
        saveImage()
        try! realm.write {
            self.diary.name = plantsName
            self.diary.comment = self.textField.text!
            self.diary.image = documentDirectoryFileURL.lastPathComponent
            self.realm.add(self.diary)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
    

    //写真を撮影、選択した時に呼ばれる
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
    
}
