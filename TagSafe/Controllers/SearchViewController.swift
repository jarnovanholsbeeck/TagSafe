//
//  SearchViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 21/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import TagListView
import DropDown

class SearchViewController: UIViewController, TagListViewDelegate, UISearchBarDelegate {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var lblSearch: UILabel!
    @IBOutlet weak var lblTags: UILabel!
    @IBOutlet weak var searchList: TagListView!
    @IBOutlet weak var tagList: TagListView!
    
    var subViewsArray: [UIView] = []
    
    var data: [String] = ["Accident", "Traffic", "Politics", "Economy", "Domestic Violence", "Environment", "Climate", "Traffic", "Politics", "Economy", "Domestic Violence", "Environment", "Climate", "Traffic", "Politics", "Economy"]
    var dataFiltered: [String] = []
    var dropButton = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        editSearchBar()
        addTags()
        
        searchBar.becomeFirstResponder()
        
        // color cancel button
        let view: UIView = self.searchBar.subviews[0] as UIView
        subViewsArray = view.subviews
        
        dataFiltered = data
        
        dropButton.anchorView = searchBar
        dropButton.bottomOffset = CGPoint(x: 0, y:(dropButton.anchorView?.plainView.bounds.height)!)
        dropButton.backgroundColor = .white
        dropButton.direction = .bottom
        
        dropButton.selectionAction = { [unowned self] (index: Int, item: String) in
            let tag = self.searchList.addTag(item)
            tag.isSelected = true
            self.dropButton.hide()
            self.searchBar.text = ""
        }
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
    
    func addTags() {
        self.tagList.addTags(["Accident", "Traffic", "Politics", "Economy", "Domestic Violence", "Environment", "Climate", "Traffic", "Politics", "Economy", "Domestic Violence", "Environment", "Climate", "Traffic", "Politics", "Economy"])
    }
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        tagView.isSelected = !tagView.isSelected
        tagView.selectedBackgroundColor = UIColor.darkGray
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataFiltered = searchText.isEmpty ? data : data.filter({ (dat) -> Bool in
            dat.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        dropButton.dataSource = dataFiltered
        dropButton.show()
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
        var searchTags :[String] = []
        let selected = searchList.tagViews
        for item in selected {
            searchTags.append(item.titleLabel!.text!)
        }
        if searchBar.text! != "" {
            searchTags.append(searchBar.text!)
        }
        print("search \(searchTags)")
        
        performSegue(withIdentifier: "ShowSearchResults", sender: self)
    }
}
