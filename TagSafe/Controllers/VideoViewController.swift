//
//  VideoViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 24/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import MobileCoreServices

class VideoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var controller = UIImagePickerController()
    let videoFileName = "/video.mp4"
    let imageFileName = "/image.png"
    var videoURL: URL!
    var imageURL: URL!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func takePicture(_ sender: Any) {
        self.takePicture()
    }
    
    @IBAction func recordVideo(_ sender: Any) {
        self.startRecording()
    }
    
    func takePicture() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.sourceType = .camera
            controller.mediaTypes = [kUTTypeImage as String]
            controller.cameraCaptureMode = .photo
            controller.delegate = self
            
            present(controller, animated: true, completion: nil)
        } else {
            print("Camera is not available")
        }
    }
    
    func startRecording() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.sourceType = .camera
            controller.mediaTypes = [kUTTypeMovie as String]
            controller.cameraCaptureMode = .video
            controller.delegate = self
            
            present(controller, animated: true, completion: nil)
        } else {
            print("Camera is not available")
        }
    }
    
    @IBAction func loadFile(_ sender: Any) {
        controller.sourceType = UIImagePickerController.SourceType.photoLibrary
        controller.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        controller.delegate = self
        
        present(controller, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 1
        if let selectedVideo:URL = (info[UIImagePickerController.InfoKey.mediaURL] as? URL) {
            print(info)

            // Save video to the main photo album
            let selectorToCall = #selector(VideoViewController.videoSaved(_:didFinishSavingWithError:context:))
            UISaveVideoAtPathToSavedPhotosAlbum(selectedVideo.relativePath, self, selectorToCall, nil)
            
            // Save the video to the app directory
            let videoData = try? Data(contentsOf: selectedVideo)
            let paths = NSSearchPathForDirectoriesInDomains(
                FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
            let dataPath = documentsDirectory.appendingPathComponent(videoFileName)
            self.videoURL = dataPath
            try! videoData?.write(to: dataPath, options: [])
        } else {
            let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
            
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            
            let imageData = image.pngData()
            let paths = NSSearchPathForDirectoriesInDomains(
                FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
            let dataPath = documentsDirectory.appendingPathComponent(imageFileName)
            self.imageURL = dataPath
            try! imageData?.write(to: dataPath, options: [])
        }
        // 3
        picker.dismiss(animated: true)
    }
    
    @objc func videoSaved(_ video: String, didFinishSavingWithError error: NSError!, context: UnsafeMutableRawPointer){
        if let error = error {
            print("error saving the video = \(error)")
        } else {
            DispatchQueue.main.async(execute: { () -> Void in
            })
            
            let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "VideoAlert") as! VideoAlertViewController
            customAlert.providesPresentationContextTransitionStyle = true
            customAlert.definesPresentationContext = true
            customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            customAlert.video = video
            customAlert.videoURL = self.videoURL
            self.present(customAlert, animated: true, completion: nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("error saving the image = \(error)")
        } else {
            DispatchQueue.main.async(execute: { () -> Void in
            })

            let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "PictureAlert") as! PictureAlertViewController
            customAlert.providesPresentationContextTransitionStyle = true
            customAlert.definesPresentationContext = true
            customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            customAlert.imageURL = self.imageURL
            self.present(customAlert, animated: true, completion: nil)
        }
    }
}
