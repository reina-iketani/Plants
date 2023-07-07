//
//  MyplantsTableViewCell.swift
//  Plants
//
//  Created by Reina Iketani on 2023/06/22.
//

import UIKit
import RealmSwift

class MyplantsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var nameLavel: UILabel!
    @IBOutlet weak var plantLavel: UILabel!
    @IBOutlet weak var waterLavel: UILabel!
    
    let realm = try! Realm()
    
    
    func setData(_ myplants: Myplants){
        self.nameLavel.text = myplants.name
        self.plantLavel.text = myplants.plants
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        let dateString:String = formatter.string(from: myplants.waterLastdate)
        self.waterLavel.text = "最終水やり日:" + dateString
        

        if let imageName = myplants.image,
            let imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(imageName),
            let imageData = try? Data(contentsOf: imageURL) {
                DispatchQueue.main.async {
                    self.plantImageView.image = UIImage(data: imageData)
                }
        } else {
            self.plantImageView.image = UIImage(named: "no_image")
        }
        
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
