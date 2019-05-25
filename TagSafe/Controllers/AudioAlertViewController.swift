//
//  AudioAlertViewController.swift
//  TagSafe
//
//  Created by Jarno Van Holsbeeck on 24/05/2019.
//  Copyright © 2019 Erasmix4. All rights reserved.
//

import UIKit
import AVKit

class AudioAlertViewController: UIViewController {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var fileTitle: UITextField!
    @IBOutlet weak var story: UITextField!
    @IBOutlet weak var tagSelector: UIView!
    
    var recordingURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Url in alert: \(recordingURL!)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 15
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }

    @IBAction func play(_ sender: Any) {
        if recordingURL != nil { // let path = Bundle.main.path(forResource: "audio", ofType: "mp3")
            let audio = AVPlayer(url: recordingURL) //URL(fileURLWithPath: path)
            let audioPlayer = AVPlayerViewController()
            audioPlayer.player = audio
            
            present(audioPlayer, animated: true, completion: {
                audio.play()
            })
        }
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        // save file to firebase
        self.dismiss(animated: true, completion: nil)
    }
}
