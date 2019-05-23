//
//  ViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 17/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import Firebase
import TagListView

class ViewController: UIViewController {
    
    var authHandle: NSObjectProtocol?
    
    var tags: [Tag] = []
    @IBOutlet weak var tagListView: TagListView!
    
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var RecordAudioButton: UIButton!
    @IBOutlet weak var RecordVideoButton: UIButton!
    @IBOutlet weak var TakeNoteButton: UIButton!
    
    var audioButtonCenter: CGPoint!
    var videoButtonCenter: CGPoint!
    var noteButtonCenter: CGPoint!
    
    @IBOutlet weak var tagName: UITextField!
    @IBOutlet weak var tagColor: UITextField!
    
    var db: Firestore?
    var loggedInUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tags.append(Tag(name: "test", color: "#F00000"))
        
        db = Firestore.firestore()
        
        audioButtonCenter = RecordAudioButton.center
        videoButtonCenter = RecordVideoButton.center
        noteButtonCenter = TakeNoteButton.center
        
        RecordAudioButton.center = AddButton.center
        RecordVideoButton.center = AddButton.center
        TakeNoteButton.center = AddButton.center
    }
    
    func getUserTags(user: User){
        
        let tagsRef = self.db!.collection("user-tags")
        
        let userTagsQuery = tagsRef.whereField("userUid", isEqualTo: user.uid).addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.tagListView.removeAllTags()
                self.tags = []
                for document in querySnapshot!.documents {
                    
                    //var data = document.data()
                    //print(document.get("name")!)
                    let newTag = Tag(name: document.get("name") as? String, color: document.get("color") as? String)
                    self.tags.append(newTag)
                    if newTag.name != nil{
                        self.tagListView.addTag(newTag.name!)
                    }
                    
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    func addUserTag(newTag: Tag){
        var dbRef: DocumentReference? = nil
        
        dbRef = db!.collection("user-tags").addDocument(data: [
            "name": newTag.name!,
            "color": newTag.color!,
            "userUid": loggedInUser?.uid
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(dbRef!.documentID)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        authHandle = Auth.auth().addStateDidChangeListener{(auth, user) in
            if let usr = user {
                print(user?.email ?? "No one logged in")
                self.loggedInUser = user
                
                self.getUserTags(user: usr)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(authHandle!)
    }
    
    @IBAction func logout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.dismiss(animated: true, completion: nil)
        } catch let logoutError as NSError {
            print("Error logging out: %@", logoutError)
        }
        
    }
    
    @IBAction func onPressAdd(_ sender: Any) {
        print(self.tags)
        if tagName.text?.isEmpty ?? true || tagColor.text?.isEmpty ?? true {
            print("nope")
            return
        }
        let newTag = Tag(name: tagName.text!, color: tagColor.text!)
        if tags.contains(where: {$0.name == newTag.name}){
            print("found")
            return
        }
        else {
            print("not found")
        }
        
        addUserTag(newTag: newTag);
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
