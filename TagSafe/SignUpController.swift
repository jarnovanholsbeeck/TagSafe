//
//  SignUpController.swift
//  TagSafe
//
//  Created by PATTYN Willem-Jan (s) on 21/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController {

    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var db: Firestore?
    
    var authHandle: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()


        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUp(_ sender: Any) {
        guard let email = emailField.text else {return}
        guard let password = passwordField.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password){ authResult, error in
            if let err = error {
                print(err)
                return
            } else {
                print("successfully created user")
            
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        authHandle = Auth.auth().addStateDidChangeListener{(auth, user) in
            print("SIGNED UP: \(user?.uid ?? "No one signed in yet")")
            if let uid = user?.uid {                
                self.db!.collection("users").document(uid).setData([
                    "files":[]
                ]) {
                    err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("User successfully added to database")
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(authHandle!)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
