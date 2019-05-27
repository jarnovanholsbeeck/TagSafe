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
    
    var recording: Bool = true
    var pictureTaken: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func takePicture(_ sender: Any) {
        switch pictureTaken {
        case true:
            pictureTaken = false
            let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "PictureAlert") as! PictureAlertViewController
            customAlert.providesPresentationContextTransitionStyle = true
            customAlert.definesPresentationContext = true
            customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(customAlert, animated: true, completion: nil)
        default:
            pictureTaken = true
        }
    }
    
    @IBAction func recordVideo(_ sender: Any) {
        switch recording {
        case true:
            //recording = false
            
            self.startRecording()
        default:
            recording = true
        }
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
            // Save video to the main photo album
            let selectorToCall = #selector(VideoViewController.videoSaved(_:didFinishSavingWithError:context:))
            
            // 2
            UISaveVideoAtPathToSavedPhotosAlbum(selectedVideo.relativePath, self, selectorToCall, nil)
            // Save the video to the app directory
            let videoData = try? Data(contentsOf: selectedVideo)
            let paths = NSSearchPathForDirectoriesInDomains(
                FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
            let dataPath = documentsDirectory.appendingPathComponent(videoFileName)
            try! videoData?.write(to: dataPath, options: [])
        }
        // 3
        picker.dismiss(animated: true)
    }
    
    @objc func videoSaved(_ video: String, didFinishSavingWithError error: NSError!, context: UnsafeMutableRawPointer){
        if let theError = error {
            print("error saving the video = \(theError)")
        } else {
            DispatchQueue.main.async(execute: { () -> Void in
            })
            
            let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "VideoAlert") as! VideoAlertViewController
            customAlert.providesPresentationContextTransitionStyle = true
            customAlert.definesPresentationContext = true
            customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            customAlert.video = video
            self.present(customAlert, animated: true, completion: nil)
        }
    }
}
