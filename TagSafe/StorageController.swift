//
//  StorageController.swift
//  TagSafe
//
//  Created by PATTYN Willem-Jan (s) on 21/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import TagListView

class StorageController: UIViewController{

    var authHandle: NSObjectProtocol?
    var db: Firestore?
    var storage: Storage?
    var mediaURL: Any?
    
    var tags: [Tag] = []
    var selectedTags: [Tag] = []
    var tagIds: [String] = []
    var loggedInUser: User?
    
    var userFiles: [File] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var searchView: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchView.delegate = self
        tagListView.delegate = self
        tableView.delegate = self
        
        
        db = Firestore.firestore()
        storage = Storage.storage()
    
        
    }
    
    @IBAction func selectImage(_ sender: Any) {
        handleSelectImage()
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        handleUploadImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        authHandle = Auth.auth().addStateDidChangeListener{(auth, user) in
            print(user?.email ?? "No one logged in")
            self.loggedInUser = user
            
            self.getUserTags(user: user!)
            self.getUserFiles(user: user!)
            
            //View stories of user in console
            let docRef = self.db!.collection("users").document(user!.uid)
            
            docRef.collection("stories").addSnapshotListener { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let fileRef = document.reference
                        
                        let data = document.get("files") as? [DocumentReference]
                        
                        data!.forEach { file in
                            //print(file.documentID)
                            
                            docRef.collection("files").document(file.documentID).addSnapshotListener { documentSnapshot, error in
                                guard let document = documentSnapshot else {
                                    print("Error fetching document: \(error!)")
                                    return
                                }
                                guard let data = document.data() else {
                                    print("Document data was empty.")
                                    return
                                }
                                print("Current data: \(data)")
                                //print(data["filename"]!)
                            }
                        }
                        
                        //print(document.data())
                        //docRef.collection("files").document(document.reference.documentID)
                        //print("\(document.documentID) => \(document.data())")
                    }
                }
            }
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(authHandle!)
    }
    
    func getUserFiles(user: User){
        
        let userFilesRef = self.db!.collection("user-files")
        
        let userFilesQuery = userFilesRef.whereField("userUid", isEqualTo: user.uid).addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
    
                    let data = document.data()
                    let file = File(id: document.documentID, name: data["filename"] as! String, detail: "detail", type: data["filetype"] as! String, date: "2019", content: data["mediaURL"] as! String)
                    
                    self.userFiles.append(file)
                    print(data)
                }
            }
        }
    }

    func getUserTags(user: User){
        
        let tagsRef = self.db!.collection("user-tags")
        
        let userTagsQuery = tagsRef.whereField("userUid", isEqualTo: user.uid).addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.tagListView.removeAllTags()
                self.tags = []
                for document in querySnapshot!.documents {
                    
                    //var data = document.data()
                    //print(document.get("name")!)
                    
                    let newTag = Tag(id: document.documentID, name: document.get("name") as? String, color: document.get("color") as? String)
                    self.tags.append(newTag)
                    if newTag.name != nil{
                        self.tagListView.addTag(newTag.name!)
                    }
                    
                    //print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    func filterUserTags(searchText: String, user: User){
        //getUserTags(user: user)
        if(searchText.isEmpty){
            getUserTags(user: user)
        } else {
            var filteredTags: [Tag] = []
            
            filteredTags = tags.filter{$0.name!.contains(searchText)}
            self.tagListView.removeAllTags()
            
            for filteredTag in filteredTags {
                //filteredTags.append(filteredTag)
                self.tagListView.addTag(filteredTag.name!)
            }
            //print(filteredTags)
        }
    }
    
    func filterFilesByTags(tags: [String], user: User){
        
        //First get all files of user
        
        let userFilesRef = self.db!.collection("user-files")
        
        let userFilesQuery = userFilesRef.whereField("userUid", isEqualTo: user.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        
                        //Then get all files with selected tags
                        self.getFilesByTags(documentID: document.documentID, tags: tags)
                    }
                }
        }
    }
    
    func getFilesByTags(documentID: String, tags: [String]){
        
        let userFileDocRef = self.db!.collection("user-files").document(documentID)
        
        userFileDocRef.getDocument { (document, error) in
            if let doc = document, doc.exists{
                
                var fileTags = [String]()
                fileTags = doc.get("tags") as? [String] ?? []
                
                if fileTags.sorted() == tags.sorted(){
                    print(doc.get("filename")!)
                    //print(fileTags)
                }
                
            } else {
                print("Document not found")
            }
        }
    }
}

extension StorageController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate {

    func handleSelectImage(){
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true)
    }
    
    func handleUploadImage(){
        let storageRef = storage?.reference()
        //print(storageRef!)
        
        let filename = ((mediaURL as! NSURL).absoluteString! as NSString).lastPathComponent
        //print(filename)
        
        //let localFile = URL(string: (mediaURL as! NSURL).absoluteString!)
        let uploadData = imageView.image!.pngData()
        
        let imageRef = storageRef!.child("image/\(filename)")

        let uploadTask = imageRef.putData(uploadData!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                print(error)
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            //print(metadata)
            // You can also access to download URL after upload.
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    print(error)
                    return
                }
                
                //Put image in database
                var dbRef: DocumentReference? = nil
                
                
                dbRef = self.db!.collection("user-files").addDocument(data: [
                    "filename": filename,
                    "filetype": "image",
                    "mediaURL": downloadURL.absoluteString,
                    "userUid": self.loggedInUser?.uid,
                    "tags": self.tagIds
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(dbRef!.documentID)")
                    }
                }
                
                //print(downloadURL)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        //print(info)
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            imageView.image = selectedImage
            mediaURL = info[.imageURL]
            //print(mediaURL!)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterUserTags(searchText: searchText.lowercased(), user: self.loggedInUser!)
    }
}

extension StorageController: TagListViewDelegate{
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        //print(title + " has been pressed")
        tagView.isHighlighted = true
        
        var filteredTag = tags.filter{$0.name! == title}
        //print(filteredTag.first?.name)
        
        if tagView.isSelected {
            tagView.isSelected = false
            selectedTags.remove(at: selectedTags.firstIndex(of: filteredTag.first!)!)
            tagIds.remove(at: tagIds.firstIndex(of: filteredTag.first!.id!)!)
            
        } else {
            tagView.isSelected = true
            selectedTags.append(filteredTag.first!)
            tagIds.append(filteredTag.first!.id!)
            
            filterFilesByTags(tags: tagIds, user: loggedInUser!)
        }

        for selectedTag in selectedTags {
            //print(selectedTag.name!)
        }
    }
}

extension StorageController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath) as! CustomFileCell
        
        cell.initFileCell(file: self.userFiles[indexPath.row])
        return cell
    }
    
    
}
