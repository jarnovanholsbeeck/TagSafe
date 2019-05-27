//
//  PinLoginViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 23/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import Firebase

class PinLoginViewController: UIViewController, UITextFieldDelegate {
    
    var userId: String!
    
    var db: Firestore?

    @IBOutlet weak var pinField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
    }
    
    @IBAction func checkPinAndContinue(_ sender: Any) {
        let userRef = self.db!.collection("users").document(userId)
        
        userRef.getDocument { (document, error) in
            if let data = document?.data() {
                let pin = data["pin"]
                let pinCheck = self.pinField.text
                if pin! as? Int == Int(pinCheck!) {
                    self.toHome()
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func toHome() {
        performSegue(withIdentifier: "ToHomeFromPin", sender: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
