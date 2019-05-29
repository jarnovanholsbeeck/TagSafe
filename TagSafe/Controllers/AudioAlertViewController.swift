//
//  AudioAlertViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 24/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import AVKit
import Firebase
import FirebaseStorage

class AudioAlertViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var fileTitle: UITextField!
    @IBOutlet weak var story: UITextField!
    @IBOutlet weak var tagSelector: TagSelector!
    
    var recordingURL: URL!
    var recordingTime: String!
    
    var tags: [Tag] = []
    var selectedTags: [Tag] = []
    var tagIds: [String] = []
    
    var db: Firestore?
    var storage: Storage?
    var mediaURL: Any?
    var userUID: String?
    
    let date = Date()
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        db = Firestore.firestore()
        storage = Storage.storage()
        userUID = UserDefaults.standard.string(forKey: "latestUserID")
        formatter.dateFormat = "dd-MM-yyyy"
        
        self.getTags()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 15
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    func getTags() {
        let tagRef = db!.collection("user-tags").whereField("userUid", isEqualTo: self.userUID!)
        
        tagRef.addSnapshotListener { (querySnapshot, err) in
            if err != nil {
                print("Error getting stories for this user.")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let tagID = document.documentID
                    let tagName = data["name"] as? String
                    let tagColor = data["color"] as? String
                    let tag = Tag(id: tagID, name: tagName!, color: tagColor!)
                    self.tags.append(tag)
                }
            }
        }
    }

    @IBAction func play(_ sender: Any) {
        if recordingURL != nil {
            let audio = AVPlayer(url: recordingURL)
            let audioPlayer = AVPlayerViewController()
            audioPlayer.player = audio
            
            present(audioPlayer, animated: true, completion: {
                audio.play()
            })
        }
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        let tags = self.tagSelector.txtTag.text
        let tagArray = tags?.components(separatedBy: .whitespacesAndNewlines)
        
        var doUpload: Bool = false
        
        for tag in self.tags {
            if (tagArray!.contains(tag.name!)) || (tagArray!.contains(tag.name!.lowercased())) {
                // add existing tag
                self.tagIds.append(tag.id!)
                
                doUpload = true
            } else {
                // create and add new tag
            }
        }
        
        if doUpload {
            self.uploadData()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func uploadData() {
        let storageRef = storage?.reference()
        let filename = fileTitle.text!
        let audioRef = storageRef!.child("audio/\(filename).m4a")
        
        audioRef.putFile(from: recordingURL, metadata: nil) { metadata, error in
            // You can also access to download URL after upload.
            audioRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    return
                }
                
                var dbRef: DocumentReference? = nil
                
                let userID = UserDefaults.standard.string(forKey: "latestUserID")
                
                let dateCreated = self.formatter.string(from: self.date)
                
                dbRef = self.db!.collection("user-files").addDocument(data: [
                    "content": downloadURL.absoluteString,
                    "dateCreated": dateCreated,
                    "detail": self.recordingTime as Any,
                    "filename": filename,
                    "filetype": "audio",
                    "tags": self.tagIds,
                    "userUid": userID!
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(dbRef!.documentID)")
                    }
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
