//
//  ViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 17/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var RecordAudioButton: UIButton!
    @IBOutlet weak var RecordVideoButton: UIButton!
    @IBOutlet weak var TakeNoteButton: UIButton!
    
    var audioButtonCenter: CGPoint!
    var videoButtonCenter: CGPoint!
    var noteButtonCenter: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioButtonCenter = RecordAudioButton.center
        videoButtonCenter = RecordVideoButton.center
        noteButtonCenter = TakeNoteButton.center
        
        RecordAudioButton.center = AddButton.center
        RecordVideoButton.center = AddButton.center
        TakeNoteButton.center = AddButton.center
    }
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        if sender.currentImage == UIImage(named: "addicon") {
            UIView.transition(with: sender, duration: 0.4, options: .transitionCrossDissolve, animations: {
                sender.setImage(UIImage(named: "closeicon"), for: .normal)
            }, completion: nil)
            
            // expand buttons
            UIView.animate(withDuration: 0.4, animations: {
                self.RecordAudioButton.alpha = 1
                self.RecordVideoButton.alpha = 1
                self.TakeNoteButton.alpha = 1
                
                self.RecordAudioButton.center = self.audioButtonCenter
                self.RecordVideoButton.center = self.videoButtonCenter
                self.TakeNoteButton.center = self.noteButtonCenter
            })
        } else {
            UIView.transition(with: sender, duration: 0.4, options: .transitionCrossDissolve, animations: {
                sender.setImage(UIImage(named: "addicon"), for: .normal)
            }, completion: nil)
            
            // hide buttons
            UIView.animate(withDuration: 0.4, animations: {
                self.RecordAudioButton.alpha = 0
                self.RecordVideoButton.alpha = 0
                self.TakeNoteButton.alpha = 0
                
                self.RecordAudioButton.center = self.AddButton.center
                self.RecordVideoButton.center = self.AddButton.center
                self.TakeNoteButton.center = self.AddButton.center
            })
        }
    }
}
