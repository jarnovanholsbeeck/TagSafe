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
    
    var tappedStory: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        db!.collection("tags").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
        
        editSearchBar()
        addRecentTags()
        addRecentStories()
        addRecentFiles()
        
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
    
    
    func addRecentTags() {
        self.tagListView.addTags(["Accident", "Traffic", "Politics", "Economy", "Domestic Violence", "Environment", "Climate", "Traffic", "Politics", "Economy"])
    }
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        tagView.isSelected = !tagView.isSelected
        tagView.selectedBackgroundColor = UIColor.darkGray
    }
    
    func addRecentStories() {
        var scrollWidth = 0
        
        for n in 0...4 {
            let startX = 16 + (n * 158)
            
            scrollWidth = startX + 166
            
            let story = StoryCardController(frame: CGRect(x: startX, y: 8, width: 150, height: 220), image: UIImage(named: "TestStory")!, name: "Traffic Jam \(n)", date: "15-06-2019", hasImage: true, hasVideo: true, hasAudio: true, hasNote: false)
            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCardTap(_:)))
            story.addGestureRecognizer(gesture)
            scrollView.addSubview(story)
        }
        
        self.scrollView.contentSize = CGSize(width: scrollWidth, height: 236)
    }
    
    @objc func handleCardTap(_ sender: UITapGestureRecognizer) {
        let card = sender.view! as? StoryCardController
        tappedStory = card?.storyName.text!
        performSegue(withIdentifier: "ShowStory", sender: self)
    }
    
    func addRecentFiles() {
        var scrollHeight = 0
        
        for n in 0...4 {
            let startY = 8 + (n * 68)
            
            scrollHeight = startY + 68
            
            let file = FileViewController(frame: CGRect(x: 16, y: startY, width: 343, height: 60), fileType: "image", filename: "TestFile", detail: "Image size", date: "12-05-2019")
            fileScrollView.addSubview(file)
        }
        
        self.fileScrollView.contentSize = CGSize(width: 343, height: scrollHeight)
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
