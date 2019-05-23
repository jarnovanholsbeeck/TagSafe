//
//  LoginViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 23/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var pin: Int!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if firstLaunch() == true {
            //stay
        } else {
            if pinEnabled() == true {
                // go to next view
                self.goToPin()
            } else {
                // stay
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func login(_ sender: Any) {
        print("login")
        showPinAlert()
    }
    
    func firstLaunch()->Bool {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "hasAppAlreadyLaunchedOnce") != nil {
            // App already launched
            return false
        } else {
            defaults.set(true, forKey: "hasAppAlreadyLaunchedOnce")
            // App launched first time
            return true
        }
    }
    
    func pinEnabled()->Bool {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "pinEnabled") == "false" {
            // no pin required
            return false
        } else {
            // pin is set
            return true
        }
    }
    
    func showPinAlert() {
        let alertController = UIAlertController(title: "Eanble Pin login", message: nil, preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (result : UIAlertAction) -> Void in
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "pinEnabled")
            self.goToHome()
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            // textfields
            let pin = alertController.textFields![0].text
            
            // set pin
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "pinEnabled")
            defaults.set(pin, forKey: "pin")
            
            self.goToPin()
        }
        
        // textfields
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Pin"
            textField.keyboardType = .numberPad
            textField.textContentType = .password
            textField.textAlignment = .center
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func goToHome() {
        performSegue(withIdentifier: "ToHome", sender: self)
    }
    
    func goToPin() {
        performSegue(withIdentifier: "InputPin", sender: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
