//
//  RecordMemosViewController.swift
//  Voice Memos
//
//  Created by Paula Luput on 3/5/23.
//  Copyright © 2023 Paula Luput. All rights reserved.
//

import UIKit
import AVFoundation

class RecordMemosViewController: UIViewController, AVAudioRecorderDelegate, UITextFieldDelegate {
    
    //************************************************//
    // MARK:- Creating Outlets.
    //************************************************//
    
    @IBOutlet weak var tapeLabel: UILabel!
    @IBOutlet weak var tapeText: UITextField!
    @IBOutlet weak var waveformView: UIView!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    //************************************************//
    // MARK: Creating properties.
    //************************************************//
    
//  variables we recieve from previous view controller
    var filename: URL!
    var numberOfRecords: Int!
    
//  variables given with "starter code"
    var recordingSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    
    var isPlay = false

    let TapeNameLabel = UILabel()
    let timerLabel = UILabel()
    
    var myTimer = Timer()
    var RemainProgess = Timer()
    var forwadlabelTimer = Timer()
    var reverselabelTimer = Timer()

    var progressValue : Float = 0
    
    var refreshControl = UIRefreshControl()
    
    var forwadpauseTime = 0
    var revsersepauseTime = 0
    var pauseProgress:Float = 0.0
    
    deinit {
        print("deinit called")
    }
    
//  variables for waveform
    // path inside the waveformView.bounds
    lazy var pencil = UIBezierPath(rect: waveformView.bounds)
    // firstPoint
    lazy var firstPoint = CGPoint(x: 6, y: (waveformView.bounds.midY))
    // jump
    lazy var jump : CGFloat = (waveformView.bounds.width - (firstPoint.x * 2))/200
    // CAShapeLayer()
    let wavelayer = CAShapeLayer()
    // traitLength
    var traitLength : CGFloat!
    // start
    var start : CGPoint!

    
    //************************************************//
    // MARK:- View life Cycle
    //************************************************//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()

//      Handle Making Label Editable
        tapeText.text = "Untitled Tape"
        tapeText.delegate = self
        tapeText.isHidden = true
        tapeLabel.isUserInteractionEnabled = true
        let aSelector : Selector = Selector(("labelTapped"))
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        tapeLabel.addGestureRecognizer(tapGesture)
        
        playButton.isHidden = true
        audioPlayer = nil
        myTimer.invalidate()
        RemainProgess.invalidate()
        forwadlabelTimer.invalidate()
        reverselabelTimer.invalidate()
        
//      Taking Care of Look of Label
        TapeNameLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        TapeNameLabel.font = TapeNameLabel.font.withSize(20)
        
//      Taking Care of Look of Timer
        timerLabel.text = "00:00:00"
        timerLabel.textColor = UIColor.darkGray
        
//      Start Recording
        writeWaves(0, false)
        startRec()

    }
    
    //************************************************//
    // MARK:- Handling Tape Name Editing
    //************************************************//
    
    func labelTapped(){
        tapeLabel.isHidden = true
        tapeText.isHidden = false
        tapeText.text = tapeLabel.text
    }

    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        tapeText.isHidden = true
        tapeLabel.isHidden = false
        tapeLabel.text = tapeText.text
        return true
    }
    
    //************************************************//
    // MARK:- Start Recording Session
    //************************************************//
    
    func startRec() {
        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        
        // Mark:- Start Audio Recording
        
        do {
            audioRecorder = try AVAudioRecorder(url: filename,settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()

            print("Recording Started")
            
            // Mark:- Start Recording Timer
            
            var counterTimer = 0
            
            myTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                
                if counterTimer == 200 {
                    self!.writeWaves(0, false)
                }
                
                self?.audioRecorder.updateMeters()
//              Write WaveForms
                self!.writeWaves((self?.audioRecorder.averagePower(forChannel: 0))!, true)

                counterTimer += 1
                
                if ((self?.audioRecorder.isRecording) != nil) {
                    self?.timerLabel.text = Manager.shared.secondsToHoursMinutesSeconds(Int((self?.audioRecorder.currentTime)!))
                    self?.TapeNameLabel.text = "Recording \(self!.numberOfRecords ?? 0)"
                }
            }
            
            
        }
        catch {
            self.displayAlert(title: "Alert!", message: "Recording failed due to some error.")
        }
    }
    
    //************************************************//
    // MARK:- Write WaveForm
    //************************************************//
    
    func writeWaves(_ input: Float, _ bool: Bool) {
        if !bool {
            start = firstPoint
            return
        }
        
        else {
            if input < -55 {
                traitLength = 0.2
            } else if input < -40 && input > -55 {
                traitLength = (CGFloat(input)+56)/3
            } else if input < -20 && input > -40 {
                traitLength = (CGFloat(input)+41)/2
            } else if input < -10 && input > -20 {
                traitLength = (CGFloat(input)+21)*5
            } else {
                traitLength = (CGFloat(input)+20)*4
            }
            
            pencil.lineWidth = jump
            
            pencil.move(to: start)
            pencil.addLine(to: CGPoint(x: start.x, y: start.y + traitLength))
            
            pencil.move(to: start)
            pencil.addLine(to: CGPoint(x: start.x, y: start.y - traitLength))
            
            wavelayer.strokeColor = UIColor.purple.cgColor
            
            wavelayer.path = pencil.cgPath
            wavelayer.fillColor = UIColor.white.cgColor
            
            wavelayer.lineWidth = jump
            
            waveformView.layer.addSublayer(wavelayer)
            wavelayer.contentsCenter = waveformView.frame
            
            waveformView.setNeedsDisplay()
            
            start = CGPoint(x: start.x + jump, y: start.y)

        }
    }
    
    
    //************************************************//
    // MARK:- IBAction Methods
    //************************************************//
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        
        // Mark:- Check if recording is active
        
        if audioRecorder == nil {
            sender.setBackgroundImage(UIImage(named: "Stop") , for: .normal)
            startRec()
        }
        
        else {
            // Mark:- Stopping Audio Recording
            
            audioRecorder.stop()
            audioRecorder = nil
            myTimer.invalidate()
            timerLabel.text = "00:00:00"

            UserDefaults.standard.set(numberOfRecords, forKey: "RecordingNumber")

            sender.setBackgroundImage(UIImage(named: "Record") , for: .normal)
            
            playButton.isHidden = false
            print("Recording Stop")
        }
    }
    
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        if !isPlay {
            sender.setBackgroundImage(UIImage(named: "Pause"), for: .normal)
            print("Recording is Playing")
    
            PlayRecording(RecordingName: String(numberOfRecords - 1))

            isPlay = true
        }
        else {
            sender.setBackgroundImage(UIImage(named: "Play") , for: .normal)
            print("Recording is Paused")
            audioPlayer.pause()
            isPlay = false
        }
    }
    
    //************************************************//
}

//extension RecordMemosViewController {
    
    // Mark:- Delete Recording Button Method
    
//    func DeleteButtonTapped(cell: RecordingsTableViewCell) {
//        let index = cell.deleteAudio.tag
//        AllRecordings.remove(at: index)
//        
//        let manager = FileManager.default
//        
//        guard let url = manager.urls(
//            for: .documentDirectory,
//            in: .userDomainMask).first else {
//            return
//        }
//        
//        AllRecordings = []
//        
//        let pathString = URL(string: "\(url)/\(cell.recordingName.text!).m4a")
//        
//        do {
//            try manager.removeItem(at: pathString!)
//            DispatchQueue.main.async {
////                self.GetRecordings()
//                self.tableView.reloadData()
//            }
//            print("Recording Deleted")
//        }
//        catch {
//            print("Got Error While Deleteing")
//        }
//        
//        print("Delete Button Tapped!")
//    }
    
    // Mark:- Play and Pause Recording Button Method
    
//    func PlayPauseTapped() {
//        let index = cell.recordingPlayPauseButton.tag
//
//        let totalRecordingTime = Manager.shared.GetRecordingTotalTime(indexpath: index)
//
//        if !isPlay {
//            pauseProgress = 0
//
//            cell.recordingPlayPauseButton.setBackgroundImage(UIImage(named: "Pause") , for: .normal)
//            print("Recording is Playing")
//
//            self.PlayRecording(RecordingName: cell.recordingName.text ?? "No Name")
//
//            if pauseProgress == 0.0 {
//                RemainProgess =  Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//
//                    if self!.progressValue <= Float(totalRecordingTime) {
//                        self?.progressValue += 1
//                        self?.pauseProgress = Float(self!.progressValue)
//                        cell.recordingProgress.progress = Float(self!.progressValue) / Float(totalRecordingTime)
//
//                        //  Float(secondPassed) / Float(totalTime)
//                    }
//                }
//            }
//            else {
//                RemainProgess =  Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//
//                    if self!.pauseProgress <= Float(totalRecordingTime) {
//                        self?.pauseProgress += 1
//                        // self.pauseProgress = self.pauseProgress
//                        cell.recordingProgress.progress =  Float(self!.pauseProgress) / Float(totalRecordingTime)
//                    }
//                }
//            }
//
//            if forwadpauseTime == 0 && revsersepauseTime == 0 {
//                var totalTime = totalRecordingTime
//                reverselabelTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//
//                    if totalTime == 0 {
//                        timer.invalidate()
//                        cell.recordingTimeRemaining.text = "-0:00"
//                        cell.recordingCurrentTime.text = "0:\(Manager.shared.GetRecordingTotalTime(indexpath: index))"
//                    }
//                    else {
//                        totalTime = totalTime - 1
//                        self?.revsersepauseTime = totalTime
//                        cell.recordingTimeRemaining.text = "-0:\(totalTime)"
//                    }
//                }
//
//                var totalTim = 0
//                forwadlabelTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//
//                    if totalTim == totalRecordingTime {
//                        timer.invalidate()
//                        cell.recordingPlayPauseButton.setBackgroundImage(UIImage(named: "Play") , for: .normal)
//                        self?.isPlay = false
//                        self?.progressValue = 0.0
//                        self?.RemainProgess.invalidate()
//                        cell.recordingProgress.progress = Float(self!.progressValue)
//                        cell.recordingTimeRemaining.text = "-0:\(Manager.shared.GetRecordingTotalTime(indexpath: index))"
//                    }
//                    else {
//                        totalTim = totalTim + 1
//                        self?.forwadpauseTime = totalTim
//                        cell.recordingCurrentTime.text = "0:\(totalTim)"
//                    }
//                }
//            }
//
//            else if forwadpauseTime != 0 && revsersepauseTime != 0 {
//                print(self.forwadpauseTime)
//                print(self.revsersepauseTime)
//
//                var totaltim = revsersepauseTime
//                reverselabelTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//
//                    if totaltim == 0 {
//                        timer.invalidate()
//                        cell.recordingTimeRemaining.text = "-0:00"
//                        cell.recordingCurrentTime.text = "0:\(Manager.shared.GetRecordingTotalTime(indexpath: index))"
//                    }
//                    else {
//                        totaltim = totaltim - 1
//                        self?.revsersepauseTime = totaltim
//                        print("Reverse Time: -\(totaltim)")
//                        cell.recordingTimeRemaining.text = "-0:\(totaltim)"
//                    }
//                }
//
//                var totaltime = forwadpauseTime
//                forwadlabelTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//
//                    if totaltime == totalRecordingTime {
//                        timer.invalidate()
//                        cell.recordingPlayPauseButton.setBackgroundImage(UIImage(named: "Play") , for: .normal)
//                        self?.isPlay = false
//                        self!.progressValue = 0.0
//                        self?.RemainProgess.invalidate()
//                        cell.recordingProgress.progress = Float(self!.progressValue)
//                        cell.recordingTimeRemaining.text = "-0:\(Manager.shared.GetRecordingTotalTime(indexpath: index))"
//                    }
//                    else {
//                        totaltime = totaltime + 1
//                        self?.forwadpauseTime = totaltime
//                        print("Forwad Time: \(totaltime)")
//                        cell.recordingCurrentTime.text = "0:\(totaltime)"
//                    }
//                }
//            }
//            self.isPlay = true
//        }
//        else {
//            cell.recordingProgress.progress = Float(self.pauseProgress)
//            cell.recordingTimeRemaining.text = "-0:\(self.revsersepauseTime)"
//            cell.recordingCurrentTime.text = "0:\(self.forwadpauseTime)"
//
//            RemainProgess.invalidate()
//            forwadlabelTimer.invalidate()
//            reverselabelTimer.invalidate()
//
//            cell.recordingPlayPauseButton.setBackgroundImage(UIImage(named: "Play") , for: .normal)
//            print("Recording is Paused")
//            audioPlayer.pause()
//            isPlay = false
//        }
//    }
//}
//
extension RecordMemosViewController {

    // Mark:- Function to Play Recording

    func PlayRecording(RecordingName: String) {
        let path = Manager.shared.getDirectory().appendingPathComponent("\(RecordingName).m4a")

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        }
        catch {
            self.displayAlert(title: "Alert!", message: "Cannot Play Recording")
        }
    }
}
    
//}
