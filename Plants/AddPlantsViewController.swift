//
//  AddPlantsViewController.swift
//  Plants
//
//  Created by Reina Iketani on 2023/06/21.
//

import UIKit
import RealmSwift
import CLImageEditor

class AddPlantsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var imageView: UIImageView!
    
    let realm = try! Realm()
    //pickerに表示するものあとで登録した植物の配列に変える
    var myplants: Myplants!
    var plantsArray: [String] = []
    var selectedPlant: String?
    
    var image: UIImage!
    var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    private var _activeTextField: UITextField? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        //キーボード
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        //picker
        pickerView.delegate = self
        pickerView.dataSource = self
        //画像の表示
        if let image = image {
            imageView.image = image
        } else{
            imageView.image = UIImage(named: "no_image")
        }
        
        //datepickerの形
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M d"
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ja_JP")
        datePicker.date = Date()
        datePicker.preferredDatePickerStyle = .wheels
        
        
        let allPlants = realm.objects(Information.self).distinct(by: ["plants"])
        plantsArray = allPlants.compactMap({ $0.plants })
        
    
        self.myplants = Myplants()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // キーボード開閉のタイミングを取得
            let notification = NotificationCenter.default
            notification.addObserver(self, selector: #selector(self.keyboardWillShow(_:)),
                                     name: UIResponder.keyboardWillShowNotification,
                                     object: nil)
            notification.addObserver(self, selector: #selector(self.keyboardWillHide(_:)),
                                     name: UIResponder.keyboardWillHideNotification,
                                     object: nil)
        }
    
    @objc func keyboardWillShow(_ notification: Notification) {

        print("呼ばれた")
        // 編集中のtextFieldを取得
        guard let textField = _activeTextField else { return }
        // キーボード、画面全体、textFieldのsizeを取得
        let rect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        guard let keyboardHeight = rect?.size.height else { return }
        let mainBoundsSize = UIScreen.main.bounds.size
        let textFieldHeight = textField.frame.height

        // ①
        let textFieldPositionY = textField.frame.origin.y + textFieldHeight
        // ②
        let keyboardPositionY = mainBoundsSize.height - keyboardHeight

        // ③キーボードをずらす
        if keyboardPositionY <= textFieldPositionY {
            let duration: TimeInterval? =
                notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
            UIView.animate(withDuration: duration!) {
                // viewをy座標方向にtransformする
                self.view.transform = CGAffineTransform(translationX: 0, y: keyboardPositionY - textFieldPositionY)
            }
        }
    }

    
    @objc func keyboardWillHide(_ notification: Notification) {
        print("呼ばれた２")
        let duration: TimeInterval? = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
        UIView.animate(withDuration: duration!) {
            self.view.transform = CGAffineTransform.identity
        }
    }

    

    @objc func dismissKeyboard(){
            // キーボードを閉じる
            view.endEditing(true)
        }
    
    //カメラボタンを押したら
    @IBAction func cameraButton(_ sender: Any) {

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    
    //ライブラリを押したら
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
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return plantsArray.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "植物を選択してください"
        } else {
            return plantsArray[row - 1]
        }
        
    }

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            selectedPlant = nil
        } else {
            selectedPlant = plantsArray[row - 1]
        }
    }
    
    
    //登録ボタンを押したら
    @IBAction func registerButton(_ sender: UIButton) {

        guard let name = textField.text, !name.isEmpty else {
            showAlert(message: "名前を入力してください")
            return
        }
        
        guard let selectedPlant = selectedPlant, !selectedPlant.isEmpty else {
            showAlert(message: "植物を選択してください")
            return
        }
         
        let existingPlant = realm.objects(Myplants.self).filter("name = %@", name).first
        if existingPlant != nil {
            showAlert(message: "同じ名前の植物がすでに存在します")
            return
        }
            
        saveImage()
        try! realm.write {
            self.myplants.image = documentDirectoryFileURL.lastPathComponent
            self.myplants.name = self.textField.text!
            self.myplants.plants = selectedPlant
            self.myplants.waterLastdate = self.datePicker.date
            self.realm.add(self.myplants)
        }
        navigationController?.popViewController(animated: true)
        
    }
    
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
    
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
                return
        }

        let keyboardHeight = view.bounds.height - keyboardFrame.origin.y
        let textFieldMaxY = textField.frame.maxY

        if textFieldMaxY > keyboardFrame.origin.y {
            let offsetY = textFieldMaxY - keyboardFrame.origin.y + 10
            UIView.animate(withDuration: animationDuration) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -offsetY)
            }
        } else {
            UIView.animate(withDuration: animationDuration) {
                self.view.transform = .identity
            }
        }
    }


}
