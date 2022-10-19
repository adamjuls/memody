//
//  ViewController.swift
//  Voice Memos
//
//  Created by Shahzaib on 3/5/22.
//  Copyright © 2022 Shahzaib. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK:- Check Microphone Permission
        
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            
            if hasPermission {
                print("Accepted")
            }
            else {
                self.displayAlert(title: "Alert!", message: "Microphone Permission is disabled")
            }
        }
    }
}
