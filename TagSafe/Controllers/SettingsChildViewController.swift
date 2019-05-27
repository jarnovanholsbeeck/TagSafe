//
//  SettingsChildViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 23/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import Firebase

class SettingsChildViewController: UIViewController {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var privacyView: UIView!
    
    //main
    @IBOutlet weak var notifications: UIButton!
    @IBOutlet weak var privacy: UIButton!
    
    //notification
    @IBOutlet weak var toggle: UISwitch!
    
    //privacy
    @IBOutlet weak var newPass: UITextField!
    @IBOutlet weak var newPassCheck: UITextField!
    @IBOutlet weak var save: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func saveNewPassword(_ sender: Any) {
        let newPassword = newPass.text
        let newPasswordCheck = newPassCheck.text
        
        if newPassword != nil && newPasswordCheck != nil && newPassword == newPasswordCheck {
            Auth.auth().currentUser?.updatePassword(to: newPassword!) { (error) in
                if error != nil {
                    print("\(String(describing: error))")
                } else {
                    self.newPass.text = ""
                    self.newPassCheck.text = ""
                    self.newPass.resignFirstResponder()
                    self.newPassCheck.resignFirstResponder()
                }
            }
        }
    }
    
    @IBAction func showNotificationView(_ sender: UIButton) {
        UIView.transition(with: sender, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.mainView.alpha = 0
            self.notificationView.alpha = 1
            self.privacyView.alpha = 0
        }, completion: nil)
    }
    
    @IBAction func showPrivacy(_ sender: UIButton) {
        UIView.transition(with: sender, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.mainView.alpha = 0
            self.notificationView.alpha = 0
            self.privacyView.alpha = 1
        }, completion: nil)
    }
    
    @IBAction func closeNotificationView(_ sender: UIButton) {
        UIView.transition(with: sender, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.mainView.alpha = 1
            self.notificationView.alpha = 0
            self.privacyView.alpha = 0
        }, completion: nil)
    }
    
    @IBAction func closePrivacyView(_ sender: UIButton) {
        UIView.transition(with: sender, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.mainView.alpha = 1
            self.notificationView.alpha = 0
            self.privacyView.alpha = 0
        }, completion: nil)
    }
}
