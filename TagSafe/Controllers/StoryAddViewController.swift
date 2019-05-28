//
//  StoryAddViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 22/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import DropDown
import Firebase

class StoryAddViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sort: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var dropButton = DropDown()
    var files: [File] = []
    let dateFormatter = DateFormatter()

    var userID: String!
    var story: String!
    var storyID: String!
    var numberOfFiles = 0
    var selectedFiles: [String] = []
    
    var db: Firestore?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        userID = UserDefaults.standard.string(forKey: "latestUserID")
        
        editSearchBar()
        loadFiles()
        
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
        print("sort \(files)")
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
        
        resetFiles()
    }
    
    func resetFiles() {
        let subViews = self.scrollView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        
        var scrollHeight = 0
        
        for n in 0...files.count-1 {
            let startY = 8 + (n * 68)
            
            scrollHeight = startY + 68
            
            let fileView = FileViewController(frame: CGRect(x: 16, y: startY, width: 343, height: 60), file: files[n], selections: true)
            
            
            if selectedFiles.contains(files[n].id) {
                fileView.selected = true
                fileView.contentView.layer.borderWidth = 1
            }
            
            scrollView.addSubview(fileView)
        }
        
        self.scrollView.contentSize = CGSize(width: 343, height: scrollHeight)
    }
    
    func loadFiles() {
        let filesRef = self.db!.collection("user-files")
        
        filesRef.addSnapshotListener { (querysnapshot, err) in
            if err != nil {
                print("Error getting stories for this user.")
            } else {
                for document in querysnapshot!.documents {
                    let data = document.data()
                    if let id = data["userUid"] as? String {
                        if id == self.userID! {
                            
                            //print("date: \(data["dateCreated"])")
                            let name = data["filename"] as? String
                            let detail = data["detail"] as? String
                            let type = data["filetype"] as? String
                            let date = data["dateCreated"] as? String
                            
                            self.showFile(id: document.documentID, name: name!, detail: detail!, type: type!, date: date!)
                        }
                    }
                }
            }
        }
    }
    
    func showFile(id: String, name: String, detail: String, type: String, date: String) {
        var scrollHeight = 0
        
        let startY = 8 + (self.numberOfFiles * 68)
        
        scrollHeight = startY + 68
        
        let file = File(id: id, name: name, detail: detail, type: type, date: date, content: "")
        files.append(file)
        let fileView = FileViewController(frame: CGRect(x: 16, y: startY, width: 343, height: 60), file: file, selections: true)
        
        if selectedFiles.contains(id) {
            fileView.selected = true
            fileView.contentView.layer.borderWidth = 1
        }
        
        scrollView.addSubview(fileView)
        
        self.scrollView.contentSize = CGSize(width: 343, height: scrollHeight)
        self.numberOfFiles += 1
    }
    
    
    @IBAction func sortAction(_ sender: Any) {
        if dropButton.isHidden == true {
            dropButton.show()
        } else {
            dropButton.hide()
        }
    }
    
    @IBAction func save(_ sender: Any) {
        // get selected files
        var selectedFiles: [String] = []
        let views = self.scrollView.subviews
        for view in views {
            if let fileView = view as? FileViewController {
                if fileView.selected == true {
                    selectedFiles.append(fileView.fileID)
                }
            } else {}
        }
        
        // save story with new files
        let storyRef = self.db!.collection("user-stories").document(storyID)
        
        storyRef.updateData([
            "files": FieldValue.arrayUnion(selectedFiles)
        ])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "BackToStory") {
            if let nextvc = segue.destination as? StoryViewController {
                nextvc.storyName = story
            }
        }
    }
}
