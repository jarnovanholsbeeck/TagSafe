//
//  StorageController.swift
//  TagSafe
//
//  Created by PATTYN Willem-Jan (s) on 21/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import FirebaseStorage

class StorageController: UIViewController{

    var storage: Storage?
    var mediaURL: Any?
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        storage = Storage.storage()
    }
    
    @IBAction func selectImage(_ sender: Any) {
        handleSelectImage()
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        handleUploadImage()
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
        
//        let localFile = URL(string: (mediaURL as? String)!)
//
//        let uploadTask = storageRef?.putFile(from: localFile!)
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
