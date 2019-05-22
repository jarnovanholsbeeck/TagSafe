//
//  StoryViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 22/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit

class StoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var storyName: String!
    
    var files: [File] = []
    
    @IBOutlet weak var story: UILabel!
    @IBOutlet weak var tableView: SelfSizedTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib.init(nibName: "CustomFileCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "FileCell")
        tableView.maxHeight = 551

        // Do any additional setup after loading the view.
        story.text = storyName
        
        showStoryFiles()
    }
    
    func showStoryFiles() {
        for n in 0...8 {
            switch n {
            case _ where n <= 4:
                let newFile = File(name: "file", detail: "detail", type: "image", date: "15-06-2019")
                self.files.append(newFile)
            case _ where n <= 8:
                let newFile = File(name: "test", detail: "detail", type: "audio", date: "12-06-2019")
                self.files.append(newFile)
            case _ where n <= 12:
                let newFile = File(name: "something", detail: "detail", type: "video", date: "10-06-2019")
                self.files.append(newFile)
            default:
                let newFile = File(name: "else", detail: "detail", type: "note", date: "5-05-2019")
                self.files.append(newFile)
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
