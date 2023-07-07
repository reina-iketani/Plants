//
//  SearchViewController.swift
//  Plants
//
//  Created by Reina Iketani on 2023/06/20.
//

import UIKit
import RealmSwift


class SearchViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.textContentType = .name
        textField.keyboardType = .namePhonePad

        // Do any additional setup after loading the view.
        
        let tapGuesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dissmissKeyboard))
        view.addGestureRecognizer(tapGuesture)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let searchResultViewController = segue.destination as? SearchResultViewController {
            searchResultViewController.plants = textField.text!
        }
            
    }

    @objc func dissmissKeyboard() {
        view.endEditing(true)
    }
    

}
