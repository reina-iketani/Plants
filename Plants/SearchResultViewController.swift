//
//  SearchResultViewController.swift
//  Plants
//
//  Created by Reina Iketani on 2023/06/21.
//

import UIKit
import RealmSwift



class SearchResultViewController: UIViewController {
    
    @IBOutlet weak var plantsLavel: UILabel!
    @IBOutlet weak var placeLavel: UILabel!
    @IBOutlet weak var waterLavel: UILabel!
    @IBOutlet weak var soilLavel: UILabel!
    @IBOutlet weak var fortuneLavel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    

    lazy var realm = try! Realm()
    
    //var plants : String?
    var plants: String?

    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if var plants = plants {
            plants = plants.katakana
            
            let plantsArray = realm.objects(Information.self).filter("plants == %@", plants)
            if let information = plantsArray.first {
                self.plantsLavel.text = information.plants
                self.placeLavel.text = "好む場所 : " + information.place
                self.waterLavel.text = "水やり : " + information.water
                self.soilLavel.text = "向いてる土 : " + information.soil
                self.fortuneLavel.text = information.fortune
                
                let contentSize = CGSize(width: scrollView.frame.width, height: fortuneLavel.frame.maxY)
                scrollView.contentSize = contentSize
            } else {
                self.plantsLavel.text = "該当する情報はありません"
                self.placeLavel.text = ""
                self.waterLavel.text = ""
                self.soilLavel.text = ""
                self.fortuneLavel.text = ""
            }
        }
    }
    
    


}

extension String {
    var katakana: String {
        let input = NSMutableString(string: self) as CFMutableString
        CFStringTransform(input, nil, kCFStringTransformHiraganaKatakana, false)
        return input as String
    }
}
