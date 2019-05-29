//
//  VideoAlertViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 24/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import AVKit
import Firebase
import FirebaseStorage

class VideoAlertViewController: UIViewController, UITextFieldDelegate {
    
    var video: String!
    var videoURL: URL!
    
    var db: Firestore?
    var storage: Storage?
    
    var userUID: String?
    
    var tags: [Tag] = []
    var selectedTags: [Tag] = []
    var tagIds: [String] = []
    
    let date = Date()
    let formatter = DateFormatter()

    @IBOutlet weak var fileTitle: UITextField!
    @IBOutlet weak var fileStory: UITextField!
    @IBOutlet weak var tagSelector: TagSelector!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        db = Firestore.firestore()
        storage = Storage.storage()
        formatter.dateFormat = "dd-MM-yyyy"
        userUID = UserDefaults.standard.string(forKey: "latestUserID")
        
        self.getTags()
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
        if video != nil {
            let video = AVPlayer(url: URL(fileURLWithPath: self.video))
            let videoPlayer = AVPlayerViewController()
            videoPlayer.player = video
            
            present(videoPlayer, animated: true, completion: {
                video.play()
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
        let videoRef = storageRef!.child("video/\(filename).mp4")
        
        videoRef.putFile(from: videoURL, metadata: nil) { metadata, error in
            // You can also access to download URL after upload.
            videoRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    return
                }
                
                var dbRef: DocumentReference? = nil
                
                let userID = UserDefaults.standard.string(forKey: "latestUserID")
                let dateCreated = self.formatter.string(from: self.date)
                let duration = AVAsset(url: self.videoURL).duration.seconds
                
                dbRef = self.db!.collection("user-files").addDocument(data: [
                    "content": downloadURL.absoluteString,
                    "dateCreated": dateCreated,
                    "detail": "\(duration)s",
                    "filename": filename,
                    "filetype": "video",
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
