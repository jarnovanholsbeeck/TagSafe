//
//  SearchViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 21/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import TagListView
import Firebase

class SearchViewController: UIViewController, TagListViewDelegate, UISearchBarDelegate {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var lblSearch: UILabel!
    @IBOutlet weak var lblTags: UILabel!
    @IBOutlet weak var searchList: TagListView!
    @IBOutlet weak var tagList: TagListView!
    
    var subViewsArray: [UIView] = []
    
    var db: Firestore?
    var userUID: String?
    
    var tags: [Tag] = []
    var tagsFiltered: [String] = []
    
    var searchItem: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        userUID = UserDefaults.standard.string(forKey: "latestUserID")

        editSearchBar()
        getTags()
        
        searchBar.becomeFirstResponder()
        
        if searchItem != "" {
            self.searchList.addTag(searchItem)
        }
        
        // color cancel button
        let view: UIView = self.searchBar.subviews[0] as UIView
        subViewsArray = view.subviews
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
    
    func getTags() {
        let tagsRef = self.db!.collection("user-tags").whereField("userUid", isEqualTo: self.userUID!)
        
            tagsRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.tagList.removeAllTags()
                self.tags = []
                for document in querySnapshot!.documents {
                    let newTag = Tag(id: document.documentID, name: document.get("name") as? String, color: document.get("color") as? String)
                    self.tags.append(newTag)
                    if newTag.name != nil{
                        self.tagList.addTag(newTag.name!)
                    }
                }
            }
        }
    }
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        tagView.isSelected = !tagView.isSelected
        //tagView.selectedBackgroundColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
        //tagView.selectedTextColor = UIColor.white
        
        if sender.tag == 1 {
            //searchTagList
            self.searchList.removeTag(title)
        } else if sender.tag == 2 {
            //TagList
            if self.tagsFiltered.contains(title) {
                
            } else {
                self.searchList.addTag(title)
                self.tagsFiltered.append(title)
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("search: \(searchText)")
        if(searchText.isEmpty){
            print("search2")
            getTags()
        } else {
            let searchArray = searchText.components(separatedBy: .whitespacesAndNewlines)
            print(searchArray)
            
            var filteredTags: [Tag] = []
            
            self.searchList.removeAllTags()
            
            for search in searchArray {
                let tag = self.tags.filter { $0.name!.lowercased().contains(search.lowercased()) }
                
                for singleTag in tag {
                    filteredTags.append(singleTag)
                }
            }
            
            for filteredTag in filteredTags {
                print(filteredTag.name!)
                self.searchList.addTag(filteredTag.name!)
                self.tagsFiltered.append(filteredTag.name!)
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        for ob: UIView in ((searchBar.subviews[0] )).subviews {
            if let z = ob as? UIButton {
                let btn: UIButton = z
                btn.setTitleColor(UIColor.white, for: .normal)
            }
        }
        // color cancel button
        for subView: UIView in self.subViewsArray {
            if subView.isKind(of: UIButton.self) {
                print(subView)
                subView.tintColor = UIColor.blue
                
                if let button = subView as? UIButton {
                    button.titleLabel?.textColor = UIColor.red
                    button.titleLabel?.text = "cancel"
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        performSegue(withIdentifier: "CancelSearch", sender: self)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var searchTags: [String] = []
        let selected = searchList.tagViews
        for item in selected {
            searchTags.append(item.titleLabel!.text!)
        }
        
        print("search \(searchTags)")
        
        let resultVC: SearchResultViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResults") as! SearchResultViewController
        resultVC.searchItems = searchTags
        self.present(resultVC, animated: true, completion: nil)
    }
}
