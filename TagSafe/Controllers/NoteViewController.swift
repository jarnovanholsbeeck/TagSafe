//
//  NoteViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 24/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtContent: UITextView!
    
    var fileChanged: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtTitle.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    @IBAction func back(_ sender: UIButton) {
        switch fileChanged {
        case true:
            // save changes
            let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "NoteAlert") as! NoteAlertViewController
            customAlert.providesPresentationContextTransitionStyle = true
            customAlert.definesPresentationContext = true
            customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            customAlert.tempTitle = txtTitle.text
            customAlert.contentText = txtContent.text
            self.present(customAlert, animated: true, completion: {
                self.fileChanged = false
            })
            
        default:
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        fileChanged = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        fileChanged = true
    }
}
