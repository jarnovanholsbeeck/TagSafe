//
//  NoteAlertViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 24/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import Firebase

class NoteAlertViewController: UIViewController {
    
    var tempTitle: String!
    var contentText: String!
    
    var db: Firestore?
    
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

        fileTitle.text = tempTitle
        
        db = Firestore.firestore()
        
        formatter.dateFormat = "dd-MM-yyyy"
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.uploadData()
    }
    
    func uploadData() {
        let filesRef = self.db!.collection("user-files")
        
        let userID = UserDefaults.standard.string(forKey: "latestUserID")
        let dateCreated = self.formatter.string(from: self.date)
        let filename = fileTitle.text!
        let words = (contentText.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }).count
        
        filesRef.addDocument(data: [
            "content": "\(contentText!)",
            "dateCreated": dateCreated,
            "detail": "\(words) words",
            "filename": filename,
            "filetype": "note",
            "tags": self.tagIds,
            "userUid": userID!
        ])
    }
}


/*
 
 */
