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

class VideoAlertViewController: UIViewController {
    
    var video: String!
    var videoURL: URL!
    
    var db: Firestore?
    var storage: Storage?
    
    var tags: [Tag] = []
    var selectedTags: [Tag] = []
    var tagIds: [String] = []
    
    let date = Date()
    let formatter = DateFormatter()

    @IBOutlet weak var fileTitle: UITextField!
    @IBOutlet weak var fileStory: UITextField!
    @IBOutlet weak var tagSelector: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        db = Firestore.firestore()
        storage = Storage.storage()
        
        formatter.dateFormat = "dd-MM-yyyy"
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
        // save to firebase
        self.dismiss(animated: true, completion: nil)
        self.uploadData()
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
}
