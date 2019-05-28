//
//  FileViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 20/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import AVKit

class FileViewController: UIView {
    let kCONTENT_XIB_NAME = "FileView"
    
    var enableSelections: Bool = false
    var selected: Bool = false
    var fileID: String!
    var file: File!
    
    var type: String!
    
    var vc: UIViewController!

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var fileType: UIImageView!
    @IBOutlet weak var filename: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init(frame: CGRect, file: File, selections: Bool, vc: UIViewController) {
        super.init(frame: frame)
        
        commonInit()
        
        self.file = file
        self.vc = vc
        enableSelections = selections
        
        contentView.layer.borderColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0).cgColor
        
        self.fileID = file.id
        
        switch file.fileType {
        case "video":
            self.type = "video"
            self.fileType.image = UIImage(named: "video")
        case "note":
            self.type = "note"
            self.fileType.image = UIImage(named: "note")
        case "audio":
            self.type = "audio"
            self.fileType.image = UIImage(named: "audio")
        default:
            self.type = "image"
            self.fileType.image = UIImage(named: "image")
        }
        self.filename.text = file.filename
        self.detail.text = file.fileDetail
        self.date.text = file.date
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
    
    @IBAction func onViewTap(_ sender: UITapGestureRecognizer) {
        if enableSelections == true {
            selected = !selected
            switch selected {
            case true:
                contentView.layer.borderColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0).cgColor
                contentView.layer.borderWidth = 1
            default:
                contentView.layer.borderWidth = 0
            }
        } else {
            // open files
            switch type {
            case "video":
                print("VideoAlert")
            case "note":
                print("NoteAlert")
            case "audio":
                print("AudioAlert \(self.file!.content)")
                if self.file!.content != "" {
                    let audioURL = URL(string: self.file!.content)!
                    let audio = AVPlayer(url: audioURL )
                    let audioPlayer = AVPlayerViewController()
                    audioPlayer.player = audio
                    
                    vc.present(audioPlayer, animated: true, completion: {
                        audio.play()
                    })
                }
            default:
                print("ImageAlert")
            }
        }
    }
}
