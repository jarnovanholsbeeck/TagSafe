//
//  StoryCardController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 20/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableView: UIView {
}

class StoryCardController: UIView {
    let kCONTENT_XIB_NAME = "StoryCard"
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var storyImage: UIImageView!
    @IBOutlet weak var storyName: UILabel!
    @IBOutlet weak var storyDate: UILabel!
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var videoIcon: UIImageView!
    @IBOutlet weak var audioIcon: UIImageView!
    @IBOutlet weak var noteIcon: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init(frame: CGRect, image: UIImage, name: String, date: String, hasImage: Bool, hasVideo: Bool, hasAudio: Bool, hasNote: Bool) {
        super.init(frame: frame)
        
        commonInit()
        
        self.storyImage.image = image
        self.storyName.text = name
        self.storyDate.text = date
        if !hasImage {
            self.imageIcon.alpha = 0
        }
        if !hasVideo {
            self.videoIcon.alpha = 0
        }
        if !hasAudio {
            self.audioIcon.alpha = 0
        }
        if !hasNote {
            self.noteIcon.alpha = 0
        }
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
