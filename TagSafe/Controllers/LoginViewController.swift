//
//  LoginViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 23/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var pin: Int!
    var toLoginUser: User?
    
    var authHandle: NSObjectProtocol?
    var db: Firestore?
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()

        if firstLaunch() == true {
            //stay
        } else {
            if pinEnabled() == true {
                // go to next view
                //self.goToPin()
            } else {
                // stay
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        authHandle = Auth.auth().addStateDidChangeListener{(auth, user) in
            self.toLoginUser = user
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(authHandle!)
    }
    
    @IBAction func login(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) { (auth, error) in
            if let err = error {
                print(err)
            } else {
                self.showPinAlert()
            }
        }
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
            
            self.setPin(user: self.toLoginUser!, pin: Int(pin!)!)
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
    
    func setPin(user: User, pin: Int) {
        let userRef = self.db!.collection("users").document(user.uid)
        
        userRef.setData(["pin": pin]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully overwritten!")
            }
        }
        
        self.goToPin()
    }
    
    func goToHome() {
        performSegue(withIdentifier: "ToHome", sender: self)
    }
    
    func goToPin() {
        let pinVC : PinLoginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PinLogin") as! PinLoginViewController
        pinVC.userId = toLoginUser?.uid
        
        self.present(pinVC, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
