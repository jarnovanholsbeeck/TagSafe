//
//  FileViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 20/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit

class FileViewController: UIView {
    let kCONTENT_XIB_NAME = "FileView"

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var fileType: UIImageView!
    @IBOutlet weak var filename: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init(frame: CGRect, fileType: String, filename: String, detail: String, date: String) {
        super.init(frame: frame)
        
        commonInit()
        
        switch fileType {
        case "video":
            self.fileType.image = UIImage(named: "video")
        case "note":
            self.fileType.image = UIImage(named: "note")
        case "audio":
            self.fileType.image = UIImage(named: "audio")
        default:
            self.fileType.image = UIImage(named: "image")
        }
        self.filename.text = filename
        self.detail.text = detail
        self.date.text = date
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        guard let content = contentView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }
}
