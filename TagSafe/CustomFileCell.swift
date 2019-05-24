//
//  CustomFileCell.swift
//  TagSafe
//
//  Created by PATTYN Willem-Jan (s) on 24/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit

class CustomFileCell: UITableViewCell {

    @IBOutlet weak var filename: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initFileCell(filename: String){
        self.filename.text = filename
    }

}
