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

class ViewController: UIViewController, TagListViewDelegate, UISearchBarDelegate {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var RecordAudioButton: UIButton!
    @IBOutlet weak var RecordVideoButton: UIButton!
    @IBOutlet weak var TakeNoteButton: UIButton!
    @IBOutlet weak var fadeScreen: UIView!
    
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var fileScrollView: UIScrollView!
    
    var audioButtonCenter: CGPoint!
    var videoButtonCenter: CGPoint!
    var noteButtonCenter: CGPoint!
    
    var db: Firestore?
    var userID: String?
    
    var numberOfStories = 0
    var numberOfFiles = 0
    var tappedStory: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        userID = UserDefaults.standard.string(forKey: "latestUserID")
        
        editSearchBar()
        getUserTags()
        getStories()
        getUserFiles()
        
        audioButtonCenter = RecordAudioButton.center
        videoButtonCenter = RecordVideoButton.center
        noteButtonCenter = TakeNoteButton.center
        
        RecordAudioButton.center = AddButton.center
        RecordVideoButton.center = AddButton.center
        TakeNoteButton.center = AddButton.center
    }
    
    func editSearchBar() {
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            textfield.borderStyle = .none
            textfield.borderStyle = .roundedRect
            textfield.font = UIFont(name: "calibretest_regular", size: 14)
            
            if let leftView = textfield.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = UIColor(red:0.00, green:0.42, blue:1.00, alpha:1.0)
            }
        }
    }
    
    func getUserTags() {
        let tagsRef = db!.collection("user-tags")
        
        tagsRef.addSnapshotListener { (querySnapshot, err) in
            if err != nil {
                print("Error getting stories for this user.")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let id = data["userUid"] as? String {
                        if id == self.userID! {
                            let newTag = Tag(id: document.documentID, name: document.get("name") as? String, color: document.get("color") as? String)
                            if newTag.name != nil{
                                self.tagListView.addTag(newTag.name!)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        let searchVC: SearchViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Search") as! SearchViewController
        searchVC.searchItem = title
        self.present(searchVC, animated: true, completion: nil)
    }
    
    func getStories() {
        let storiesRef = self.db!.collection("user-stories")
        
        storiesRef.addSnapshotListener { (querysnapshot, err) in
            if err != nil {
                print("Error getting stories for this user.")
            } else {
                for document in querysnapshot!.documents {
                    let data = document.data()
                    if let id = data["userUid"] as? String {
                        if id == self.userID! {
                            let name = document.get("title") as! String
                            let date = document.get("dateCreated") as! String
                            let image = document.get("thumbnail") as! String
                            
                            let hasImage = true
                            let hasVideo = true
                            let hasAudio = true
                            let hasNote = true
                            
                            self.addStory(name: name, date: date, image: image, hasImage: hasImage, video: hasVideo, audio: hasAudio, note: hasNote)
                        }
                    }
                }
            }
        }
    }
    
    func addStory(name: String, date: String, image: String, hasImage: Bool, video: Bool, audio: Bool, note: Bool) {
        var scrollWidth = 0
        let startX = 16 + (numberOfStories * 158)
        scrollWidth = startX + 166
        
        let story = StoryCardController(frame: CGRect(x: startX, y: 8, width: 150, height: 220), image: image, name: name, date: date, hasImage: hasImage, hasVideo: video, hasAudio: audio, hasNote: note)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCardTap(_:)))
        story.addGestureRecognizer(gesture)
        scrollView.addSubview(story)
        
        self.scrollView.contentSize = CGSize(width: scrollWidth, height: 236)
        numberOfStories += 1
    }
    
    @objc func handleCardTap(_ sender: UITapGestureRecognizer) {
        let card = sender.view! as? StoryCardController
        tappedStory = card?.storyName.text!
        performSegue(withIdentifier: "ShowStory", sender: self)
    }
    
    func getUserFiles() {
        let filesRef = self.db!.collection("user-files")
        
        filesRef.addSnapshotListener { (querysnapshot, err) in
            if err != nil {
                print("Error getting stories for this user.")
            } else {
                for document in querysnapshot!.documents {
                    let data = document.data()
                    if let id = data["userUid"] as? String {
                        if id == self.userID! {
                            
                            let name = data["filename"] as? String
                            let detail = data["detail"] as? String
                            let type = data["filetype"] as? String
                            let date = data["dateCreated"] as? String
                            let content = data["content"] as? String
                            
                            self.addFile(id: self.userID!, name: name!, detail: detail!, type: type!, date: date!, content: content!)
                        }
                    }
                }
            }
        }
    }
    
    func addFile(id: String, name: String, detail: String, type: String, date: String, content: String) {
        var scrollHeight = 0
        
        let startY = 8 + (numberOfFiles * 68)
        
        scrollHeight = startY + 68
        
        let file = File(id: id, name: name, detail: detail, type: type, date: date, content: content)
        let fileView = FileViewController(frame: CGRect(x: 16, y: startY, width: 343, height: 60), file: file, selections: false, vc: self)
        fileScrollView.addSubview(fileView)
    
        self.fileScrollView.contentSize = CGSize(width: 343, height: scrollHeight)
        
        numberOfFiles += 1
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
                self.contentView.insertSubview(self.fadeScreen, aboveSubview: self.fileScrollView)
                self.fadeScreen.alpha = 1
                
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
                self.contentView.sendSubviewToBack(self.fadeScreen)
                self.fadeScreen.alpha = 0
                
                self.RecordAudioButton.center = self.AddButton.center
                self.RecordVideoButton.center = self.AddButton.center
                self.TakeNoteButton.center = self.AddButton.center
            })
        }
    }
    
    @IBAction func fadePush(_ sender: UITapGestureRecognizer) {
        self.AddButton.sendActions(for: .touchUpInside)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        performSegue(withIdentifier: "Search", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowStory") {
            if let nextvc = segue.destination as? StoryViewController {
                nextvc.storyName = tappedStory
            }
        }
    }
}
