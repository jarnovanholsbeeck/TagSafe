//
//  StoryAddViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 22/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import DropDown

class StoryAddViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sort: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var dropButton = DropDown()
    var files: [File] = []
    let dateFormatter = DateFormatter()

    var story: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        editSearchBar()
        showAllFiles()
        
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
            
            let fileView = FileViewController(frame: CGRect(x: 16, y: startY, width: 343, height: 60), file: files[n])
            scrollView.addSubview(fileView)
        }
        
        self.scrollView.contentSize = CGSize(width: 343, height: scrollHeight)
    }
    
    func showAllFiles() {
        var scrollHeight = 0
        
        for n in 0...9 {
            let startY = 8 + (n * 68)
            
            scrollHeight = startY + 68
            
            let file = File(id: "", name: "File \(n+1)", detail: "File detail", type: "audio", date: "15-\(n+1)-2019", content: "")
            files.append(file)
            let fileView = FileViewController(frame: CGRect(x: 16, y: startY, width: 343, height: 60), file: file)
            scrollView.addSubview(fileView)
        }
        
        self.scrollView.contentSize = CGSize(width: 343, height: scrollHeight)
    }
    
    
    @IBAction func sortAction(_ sender: Any) {
        if dropButton.isHidden == true {
            dropButton.show()
        } else {
            dropButton.hide()
        }
    }
    
    @IBAction func save(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "BackToStory") {
            if let nextvc = segue.destination as? StoryViewController {
                nextvc.storyName = story
            }
        }
    }
}
