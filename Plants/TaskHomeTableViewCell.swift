//
//  TaskHomeTableViewCell.swift
//  Plants
//
//  Created by Reina Iketani on 2023/06/23.
//

import UIKit


class TaskHomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lavel: UILabel!
    @IBOutlet weak var button: UIButton!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
