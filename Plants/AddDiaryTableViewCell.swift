//
//  AddDiaryTableViewCell.swift
//  Plants
//
//  Created by Reina Iketani on 2023/06/26.
//

import UIKit
import RealmSwift

class AddDiaryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var diaryImageView: UIImageView!
    @IBOutlet weak var dateLavel: UILabel!
    @IBOutlet weak var commentLavel: UILabel!
    
    
    let realm = try! Realm()
    
    func setData(_ diary: Diary){
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d EEE"
        let dateString:String = formatter.string(from: diary.date)
        self.dateLavel.text = dateString
        
        self.commentLavel.text = diary.comment
        
        if let imageName = diary.image,
            let imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(imageName),
            let imageData = try? Data(contentsOf: imageURL) {
                DispatchQueue.main.async {
                    self.diaryImageView.image = UIImage(data: imageData)
                }
        } else {
            self.diaryImageView.image = UIImage(named: "no_image")
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
