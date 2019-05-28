//
//  AllDataViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 23/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import DropDown
import Firebase

class AllDataViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var recordAudioButton: UIButton!
    @IBOutlet weak var recordVideoButton: UIButton!
    @IBOutlet weak var takeNoteButton: UIButton!
    @IBOutlet weak var fadeScreen: UIView!
    
    var dropButton = DropDown()
    var files: [File] = []
    var fileIDs: [String] = []
    let dateFormatter = DateFormatter()
    
    var db: Firestore?
    var userID: String?
    
    var numberOfFiles = 0
    
    var audioButtonCenter: CGPoint!
    var videoButtonCenter: CGPoint!
    var noteButtonCenter: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        db = Firestore.firestore()
        
        userID = UserDefaults.standard.string(forKey: "latestUserID")
        
        let nib = UINib.init(nibName: "CustomFileCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "FileCell")
        
        editSearchBar()
        showFiles()
        
        dropButton.anchorView = sortButton
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
        
        audioButtonCenter = recordAudioButton.center
        videoButtonCenter = recordVideoButton.center
        noteButtonCenter = takeNoteButton.center
        
        recordAudioButton.center = addButton.center
        recordVideoButton.center = addButton.center
        takeNoteButton.center = addButton.center
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
    
    func showFiles() {
        let fileRef = db!.collection("user-files")
        
        fileRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let name = document.get("filename") as? String
                    let detail = document.get("detail") as? String
                    let type = document.get("filetype") as? String
                    let date = document.get("dateCreated") as? String
                    let content = document.get("content") as? String
                    
                    let newFile = File(id: document.documentID, name: name!, detail: detail!, type: type!, date: date!, content: content!)
                    
                    self.files.append(newFile)
                    self.fileIDs.append(document.documentID)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            db!.collection("user-files").document(fileIDs[indexPath.row]).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            files.remove(at: indexPath.row)
            fileIDs.remove(at: indexPath.row)
            
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
    
    @IBAction func sortAction(_ sender: UIButton) {
        if dropButton.isHidden == true {
            dropButton.show()
        } else {
            dropButton.hide()
        }
    }
    
    @IBAction func fadeScreenTap(_ sender: UITapGestureRecognizer) {
        self.addButton.sendActions(for: .touchUpInside)
    }
    
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        if sender.currentImage == UIImage(named: "addicon") {
            UIView.transition(with: sender, duration: 0.4, options: .transitionCrossDissolve, animations: {
                sender.setImage(UIImage(named: "closeicon"), for: .normal)
            }, completion: nil)
            
            // expand buttons
            UIView.animate(withDuration: 0.4, animations: {
                self.recordAudioButton.alpha = 1
                self.recordVideoButton.alpha = 1
                self.takeNoteButton.alpha = 1
                self.contentView.insertSubview(self.fadeScreen, aboveSubview: self.tableView)
                self.fadeScreen.alpha = 1
                
                self.recordAudioButton.center = self.audioButtonCenter
                self.recordVideoButton.center = self.videoButtonCenter
                self.takeNoteButton.center = self.noteButtonCenter
            })
        } else {
            UIView.transition(with: sender, duration: 0.4, options: .transitionCrossDissolve, animations: {
                sender.setImage(UIImage(named: "addicon"), for: .normal)
            }, completion: nil)
            
            // hide buttons
            UIView.animate(withDuration: 0.4, animations: {
                self.recordAudioButton.alpha = 0
                self.recordVideoButton.alpha = 0
                self.takeNoteButton.alpha = 0
                self.fadeScreen.alpha = 0
                self.contentView.sendSubviewToBack(self.fadeScreen)
                
                self.recordAudioButton.center = self.addButton.center
                self.recordVideoButton.center = self.addButton.center
                self.takeNoteButton.center = self.addButton.center
            })
        }
    }
}
