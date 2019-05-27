//
//  StoryViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 22/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import Firebase

class StoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var userID: String!
    var storyName: String!
    
    var files: [File] = []
    
    var db: Firestore?
    
    @IBOutlet weak var story: UILabel!
    @IBOutlet weak var tableView: SelfSizedTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userID = UserDefaults.standard.string(forKey: "latestUserID")
        
        db = Firestore.firestore()
        
        let nib = UINib.init(nibName: "CustomFileCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "FileCell")
        tableView.maxHeight = 551

        // Do any additional setup after loading the view.
        story.text = storyName
        
        getStory()
    }
    
    func getStory() {
        let storyRef = db!.collection("user-stories")
        
        storyRef.whereField("title", isEqualTo: storyName!).addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.get("files") as? [String]
                    for file in data! {
                        self.getFile(file: file)
                    }
                }
            }
        }
    }
    
    func getFile(file: String) {
        let fileRef = db!.collection("user-files").document(file)
        
        fileRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let document = querySnapshot!
                
                let name = document.get("filename") as? String
                let detail = document.get("detail") as? String
                let type = document.get("filetype") as? String
                let date = document.get("dateCreated") as? String
                let content = document.get("content") as? String
                
                let newFile = File(id: self.userID, name: name!, detail: detail!, type: type!, date: date!, content: content!)
                
                self.files.append(newFile)
                self.tableView.reloadData()
                self.tableView.frame = CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y, width: self.tableView.frame.size.width, height: self.tableView.contentSize.height)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath) as! CustomFileCell
        cell.filename.text = self.files[indexPath.row].filename
        cell.fileDetail.text = self.files[indexPath.row].fileDetail
        cell.date.text = self.files[indexPath.row].date
        switch self.files[indexPath.row].fileType {
        case "video":
            cell.fileType.image = UIImage(named: "play_circle")
        case "audio":
            cell.fileType.image = UIImage(named: "audio")
        case "note":
            cell.fileType.image = UIImage(named: "note")
        default:
            cell.fileType.image = UIImage(named: "image")
        }
        
        cell.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)
        
        return cell
    }
    
    @IBAction func addFiles(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "AddFiles") {
            if let nextvc = segue.destination as? StoryAddViewController {
                nextvc.story = self.storyName
            }
        }
    }
}
