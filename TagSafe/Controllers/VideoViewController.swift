//
//  VideoViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 24/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {
    
    var recording: Bool = false
    var pictureTaken: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func takePicture(_ sender: Any) {
        switch pictureTaken {
        case true:
            pictureTaken = false
            let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "PictureAlert") as! PictureAlertViewController
            customAlert.providesPresentationContextTransitionStyle = true
            customAlert.definesPresentationContext = true
            customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(customAlert, animated: true, completion: nil)
        default:
            pictureTaken = true
        }
    }
    
    @IBAction func recordVideo(_ sender: Any) {
        switch recording {
        case true:
            recording = false
            let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "VideoAlert") as! VideoAlertViewController
            customAlert.providesPresentationContextTransitionStyle = true
            customAlert.definesPresentationContext = true
            customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(customAlert, animated: true, completion: nil)
        default:
            recording = true
        }
    }
    
    @IBAction func loadFile(_ sender: Any) {
    }
}
