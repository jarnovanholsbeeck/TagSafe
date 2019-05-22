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

class StorageController: UIViewController{

    var authHandle: NSObjectProtocol?
    var db: Firestore?
    var storage: Storage?
    var mediaURL: Any?
    
    var loggedInUser: User?
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
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
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(authHandle!)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension StorageController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func handleSelectImage(){
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true)
    }
    
    func handleUploadImage(){
        let storageRef = storage?.reference()
        print(storageRef!)
        
        let filename = ((mediaURL as! NSURL).absoluteString! as NSString).lastPathComponent
        print(filename)
        
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
            print(metadata)
            // You can also access to download URL after upload.
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    print(error)
                    return
                }
                let userRef = self.db!.collection("users").document(self.loggedInUser!.uid)

                let tag = Tag(name: "bla", color: "bla")
                userRef.updateData([
                    "files": FieldValue.arrayUnion([
                        [
                            "filename": filename,
                            "filetype": "image",
                            "tags": [],
                            "mediaURL": downloadURL.absoluteString
                        ]
                        ])
                ])
                
                print(downloadURL)
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
            print(mediaURL!)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
