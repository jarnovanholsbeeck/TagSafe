//
//  SettingsViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 23/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var recordAudioButton: UIButton!
    @IBOutlet weak var recordVideoButton: UIButton!
    @IBOutlet weak var takeNoteButton: UIButton!
    @IBOutlet weak var fadeScreen: UIView!
    @IBOutlet weak var containerView: UIView!
    
    var audioButtonCenter: CGPoint!
    var videoButtonCenter: CGPoint!
    var noteButtonCenter: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        audioButtonCenter = recordAudioButton.center
        videoButtonCenter = recordVideoButton.center
        noteButtonCenter = takeNoteButton.center
        
        recordAudioButton.center = addButton.center
        recordVideoButton.center = addButton.center
        takeNoteButton.center = addButton.center
    }
    
    @IBAction func AddButtonClicked(_ sender: UIButton) {
        if sender.currentImage == UIImage(named: "addicon") {
            UIView.transition(with: sender, duration: 0.4, options: .transitionCrossDissolve, animations: {
                sender.setImage(UIImage(named: "closeicon"), for: .normal)
            }, completion: nil)
            
            // expand buttons
            UIView.animate(withDuration: 0.4, animations: {
                self.recordAudioButton.alpha = 1
                self.recordVideoButton.alpha = 1
                self.takeNoteButton.alpha = 1
                self.contentView.insertSubview(self.fadeScreen, aboveSubview: self.containerView)
                self.fadeScreen.alpha = 1
                
                self.recordAudioButton.center = self.audioButtonCenter
                self.recordVideoButton.center = self.videoButtonCenter
                self.takeNoteButton.center = self.noteButtonCenter
            })
        } else {
            UIView.transition(with: sender, duration: 0.4, options: .transitionCrossDissolve, animations: {
                sender.setImage(UIImage(named: "addicon"), for: .normal)
            }, completion: nil)
            
            // hide buttons
            UIView.animate(withDuration: 0.4, animations: {
                self.recordAudioButton.alpha = 0
                self.recordVideoButton.alpha = 0
                self.takeNoteButton.alpha = 0
                self.fadeScreen.alpha = 0
                self.contentView.sendSubviewToBack(self.fadeScreen)
                
                self.recordAudioButton.center = self.addButton.center
                self.recordVideoButton.center = self.addButton.center
                self.takeNoteButton.center = self.addButton.center
            })
        }
    }
    
    @IBAction func fadePush(_ sender: UITapGestureRecognizer) {
        self.addButton.sendActions(for: .touchUpInside)
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*if (segue.identifier == "ShowStory") {
            if let nextvc = segue.destination as? StoryViewController {
                nextvc.storyName = tappedStory
            }
        }*/
    }
}
