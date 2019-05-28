//
//  SearchResultViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 21/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import DropDown
import Firebase

class SearchResultViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sort: UIButton!
    
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var RecordAudioButton: UIButton!
    @IBOutlet weak var RecordVideoButton: UIButton!
    @IBOutlet weak var TakeNoteButton: UIButton!
    @IBOutlet weak var fadeScreen: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var audioButtonCenter: CGPoint!
    var videoButtonCenter: CGPoint!
    var noteButtonCenter: CGPoint!
    
    var dropButton = DropDown()
    
    var db: Firestore?
    var userID: String?
    
    var searchItems: [String] = []
    
    var files: [File] = []
    var fileIDs: [String] = []
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        db = Firestore.firestore()
        
        userID = UserDefaults.standard.string(forKey: "latestUserID")
        
        let nib = UINib.init(nibName: "CustomFileCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "FileCell")
        
        editSearchBar()
        showSearchedFiles()
        
        dropButton.anchorView = sort
        dropButton.bottomOffset = CGPoint(x: 0, y:(dropButton.anchorView?.plainView.bounds.height)!)
        dropButton.backgroundColor = .white
        dropButton.direction = .bottom
        dropButton.dataSource = ["Date", "A -> Z", "Z -> A"]
        
        dropButton.selectionAction = { [unowned self] (index: Int, item: String) in
            print("\(item)")
            self.sortFiles(sortStyle: item)
            self.dropButton.hide()
        }
        
        dateFormatter.dateFormat = "dd-MM-yyyy"

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
    
    func showSearchedFiles() {
        let fileRef = db!.collection("user-files").whereField("userUid", isEqualTo: self.userID!)
        
        fileRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let tagRefs = document.get("tags") as? [String]
                    
                    var documentTags: [String] = []
                    
                    let id = document.documentID
                    let name = document.get("filename") as? String
                    let detail = document.get("detail") as? String
                    let type = document.get("filetype") as? String
                    let date = document.get("dateCreated") as? String
                    let content = document.get("content") as? String
                    
                    // get tags from file
                    for tag in tagRefs! {
                        self.db!.collection("user-tags").document(tag).getDocument { (document, error) in
                            if let document = document, document.exists {
                                let tagName = document.get("name") as? String
                                documentTags.append(tagName!)
                                
                                for item in self.searchItems {
                                    if documentTags.contains(item) {
                                        self.showFiles(id: id, name: name!, detail: detail!, type: type!, date: date!, content: content!)
                                    }
                                }
                            } else {
                                print("Document does not exist")
                            }
                        }
                    }                    
                }
            }
        }
    }
    
    func showFiles(id: String, name: String, detail: String, type: String, date: String, content: String) {
        let newFile = File(id: id, name: name, detail: detail, type: type, date: date, content: content)
        
        self.files.append(newFile)
        self.fileIDs.append(id)
        self.tableView.reloadData()
    }
    
    func sortFiles(sortStyle: String) {
        switch sortStyle {
        case "date":
            files = files.sorted(by: { dateFormatter.date(from: $0.date)! < dateFormatter.date(from: $1.date)! })
        case "A -> Z":
            files = files.sorted(by: { $0.filename < $1.filename })
        case "Z -> A":
            files = files.sorted(by: { $0.filename > $1.filename })
        default:
            files = files.sorted(by: { dateFormatter.date(from: $0.date)! < dateFormatter.date(from: $1.date)! })
        }
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        performSegue(withIdentifier: "SearchAgain", sender: self)
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
                self.contentView.insertSubview(self.fadeScreen, aboveSubview: self.tableView)
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
    
    @IBAction func sortAction(_ sender: UIButton) {
        if dropButton.isHidden == true {
            dropButton.show()
        } else {
            dropButton.hide()
        }
    }
    
    @IBAction func fadePush(_ sender: UITapGestureRecognizer) {
        self.AddButton.sendActions(for: .touchUpInside)
    }
    
    //TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
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
}
