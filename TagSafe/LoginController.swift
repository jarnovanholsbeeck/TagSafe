//
//  LoginController.swift
//  TagSafe
//
//  Created by PATTYN Willem-Jan (s) on 21/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {

    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var authHandle: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        authHandle = Auth.auth().addStateDidChangeListener{(auth, user) in
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(authHandle!)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
    }

}
