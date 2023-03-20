//
//  RecordMemosViewController.swift
//  Voice Memos
//
//  Created by Shahzaib on 3/5/22.
//  Copyright © 2022 Shahzaib. All rights reserved.
//

import UIKit
import AVFoundation

class RecordMemosViewController: UIViewController, AVAudioRecorderDelegate {
    
    //************************************************//
    // MARK:- Creating Outlets.
    //************************************************//
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var tapLabel: UILabel!
    @IBOutlet weak var recordingButtonView: UIView!
    
    //************************************************//
    // MARK: Creating properties.
    //************************************************//
    
    var recordingSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    
    var isPlay = false
    
    let PopUpView = UIView()
    let RecoringNameLabel = UILabel()
    let timerLabel = UILabel()
    
    var myTimer = Timer()
    var RemainProgess = Timer()
    var forwadlabelTimer = Timer()
    var reverselabelTimer = Timer()
    
    var numberOfRecords:Int = 0
    var progressValue : Float = 0
    
    var AllRecordings = [String]()
    
    var refreshControl = UIRefreshControl()
    
    var forwadpauseTime = 0
    var revsersepauseTime = 0
    var pauseProgress:Float = 0.0
    
    deinit {
        print("deinit called")
    }
    
    //************************************************//
    // MARK:- View life Cycle
    //************************************************//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AllRecordings = []
        
        tapLabel.isHidden = true
        PopUpView.isHidden = true
        
        recordingSession = AVAudioSession.sharedInstance()
        
        if let Number: Int =  UserDefaults.standard.value(forKey: "RecordingNumber") as? Int {
            numberOfRecords = Number
            print(Number)
        }
        
        CreatePopUpView()
        
        GetRecordings()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        
        refreshControl.addTarget(self, action: #selector(PulltoRefresh(sender:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    //************************************************//
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        audioPlayer = nil
        myTimer.invalidate()
        RemainProgess.invalidate()
        forwadlabelTimer.invalidate()
        reverselabelTimer.invalidate()
    }
    
    //************************************************//
    // MARK:- Custom methods, actions and selectors.
    //************************************************//
    
    @objc func PulltoRefresh(sender: UIRefreshControl) {
        sender.endRefreshing()
        tableView.reloadData()
    }
    
    //************************************************//
    
    func CreatePopUpView() {
        
        PopUpView.backgroundColor = UIColor.systemGray5
        view.addSubview(PopUpView)
        
        PopUpView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            PopUpView.bottomAnchor.constraint(equalTo: recordingButtonView.topAnchor, constant: 0),
            PopUpView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            PopUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            PopUpView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3)
        ])
        
        RecoringNameLabel.text = "Recording 1"
        RecoringNameLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        RecoringNameLabel.font = RecoringNameLabel.font.withSize(20)
        RecoringNameLabel.translatesAutoresizingMaskIntoConstraints = false
        PopUpView.addSubview(RecoringNameLabel)
        
        NSLayoutConstraint.activate([
            
            RecoringNameLabel.topAnchor.constraint(equalTo: PopUpView.topAnchor, constant: 20),
            RecoringNameLabel.centerXAnchor.constraint(equalTo: PopUpView.centerXAnchor)
        ])
        
        timerLabel.text = "00:00:00"
        timerLabel.textColor = UIColor.darkGray
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        PopUpView.addSubview(timerLabel)
        
        NSLayoutConstraint.activate([
            
            timerLabel.topAnchor.constraint(equalTo: RecoringNameLabel.bottomAnchor, constant: 10),
            timerLabel.centerXAnchor.constraint(equalTo: PopUpView.centerXAnchor)
        ])
    }
    
    //************************************************//
    
    // MARK:- IBAction Methods
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        
        // Mark:- Check if recording is active
        
        if audioRecorder == nil {
            numberOfRecords += 1
            let filename = Manager.shared.getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
            
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            // Mark:- Start Audio Recording
            
            do {
                audioRecorder = try AVAudioRecorder(url: filename,settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                sender.setBackgroundImage(UIImage(named: "Square") , for: .normal)
                print("Recording Start")
                PopUpView.isHidden = false
                
                // Mark:- Start Recording Timer
                
                myTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                    
                    if ((self?.audioRecorder.isRecording) != nil) {
                        self?.timerLabel.text = Manager.shared.secondsToHoursMinutesSeconds(Int((self?.audioRecorder.currentTime)!))
                        self?.RecoringNameLabel.text = "Recording \(self!.numberOfRecords)"
                    }
                }
            }
            catch {
                self.displayAlert(title: "Alert!", message: "Recording failed due to some error.")
            }
        }
        
        else {
            // Mark:- Stopping Audio Recording
            
            audioRecorder.stop()
            audioRecorder = nil
            myTimer.invalidate()
            timerLabel.text = "00:00:00"
            
            UserDefaults.standard.set(numberOfRecords, forKey: "RecordingNumber")
            
            sender.setBackgroundImage(UIImage(named: "Circle") , for: .normal)
            print("Recording Stop")
            PopUpView.isHidden = true
            
            GetRecordings()
        }
    }
    
    //************************************************//
}

extension RecordMemosViewController : UITableViewDelegate,UITableViewDataSource {
    
    //************************************************//
    // MARK:- UITableview delegate and datesource
    //************************************************//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    //************************************************//
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if numberOfRecords == 0 {
            tapLabel.isHidden = false
            tableView.isHidden = true
            return 0
        }
        
        else {
            tapLabel.isHidden = true
            tableView.isHidden = false
            return AllRecordings.count
        }
    }
    
    //************************************************//
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! RecordingsTableViewCell
        
        cell.recordingName.text = AllRecordings[indexPath.row]
        
        cell.recordedCurrentTime.text = "\(Manager.shared.GetRecordingSaveTime(indexpath: indexPath.row))"
        cell.recordingTimeRemaining.text = "-0:\(Manager.shared.GetRecordingTotalTime(indexpath: indexPath.row))"
        cell.recordingCurrentTime.text = "0:\(Manager.shared.GetRecordingTotalTime(indexpath: indexPath.row))"
        
        cell.recordingProgress.tag = indexPath.row
        
        cell.delegate = self
        cell.recordingPlayPauseButton.tag = indexPath.row
        cell.deleteAudio.tag = indexPath.row
        cell.convertMIDI.tag = indexPath.row

        
        return cell
    }
    
    //************************************************//
}

extension RecordMemosViewController : RecordingsTableViewCellProtocols {
    
    // Mark:- MIDI Button Method
    func MIDIButtonTapped(cell: RecordingsTableViewCell, RecordingName: String) {
        let path = Manager.shared.getDirectory().appendingPathComponent("\(RecordingName).m4a")
        print(path)
    }
    
    // Mark:- Delete Recording Button Method
    func DeleteButtonTapped(cell: RecordingsTableViewCell) {
        let index = cell.deleteAudio.tag
        AllRecordings.remove(at: index)
        
        let manager = FileManager.default
        
        guard let url = manager.urls(
            for: .documentDirectory,
            in: .userDomainMask).first else {
            return
        }
        
        AllRecordings = []
        
        let pathString = URL(string: "\(url)/\(cell.recordingName.text!).m4a")
        
        do {
            try manager.removeItem(at: pathString!)
            DispatchQueue.main.async {
                self.GetRecordings()
                self.tableView.reloadData()
            }
            print("Recording Deleted")
        }
        catch {
            print("Got Error While Deleteing")
        }
        
        print("Delete Button Tapped!")
    }
    
    // Mark:- Play and Pause Recording Button Method
    
    func PlayPauseTapped(cell: RecordingsTableViewCell) {
        let index = cell.recordingPlayPauseButton.tag
        
        let totalRecordingTime = Manager.shared.GetRecordingTotalTime(indexpath: index)
        
        if !isPlay {
            pauseProgress = 0
            
            cell.recordingPlayPauseButton.setBackgroundImage(UIImage(named: "Pause") , for: .normal)
            print("Recording is Playing")
            
            self.PlayRecording(RecordingName: cell.recordingName.text ?? "No Name")
            
            if pauseProgress == 0.0 {
                RemainProgess =  Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                    
                    if self!.progressValue <= Float(totalRecordingTime) {
                        self?.progressValue += 1
                        self?.pauseProgress = Float(self!.progressValue)
                        cell.recordingProgress.progress = Float(self!.progressValue) / Float(totalRecordingTime)
                        
                        //  Float(secondPassed) / Float(totalTime)
                    }
                }
            }
            else {
                RemainProgess =  Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                    
                    if self!.pauseProgress <= Float(totalRecordingTime) {
                        self?.pauseProgress += 1
                        // self.pauseProgress = self.pauseProgress
                        cell.recordingProgress.progress =  Float(self!.pauseProgress) / Float(totalRecordingTime)
                    }
                }
            }
            
            if forwadpauseTime == 0 && revsersepauseTime == 0 {
                var totalTime = totalRecordingTime
                reverselabelTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                    
                    if totalTime == 0 {
                        timer.invalidate()
                        cell.recordingTimeRemaining.text = "-0:00"
                        cell.recordingCurrentTime.text = "0:\(Manager.shared.GetRecordingTotalTime(indexpath: index))"
                    }
                    else {
                        totalTime = totalTime - 1
                        self?.revsersepauseTime = totalTime
                        cell.recordingTimeRemaining.text = "-0:\(totalTime)"
                    }
                }
                
                var totalTim = 0
                forwadlabelTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                    
                    if totalTim == totalRecordingTime {
                        timer.invalidate()
                        cell.recordingPlayPauseButton.setBackgroundImage(UIImage(named: "Play") , for: .normal)
                        self?.isPlay = false
                        self?.progressValue = 0.0
                        self?.RemainProgess.invalidate()
                        cell.recordingProgress.progress = Float(self!.progressValue)
                        cell.recordingTimeRemaining.text = "-0:\(Manager.shared.GetRecordingTotalTime(indexpath: index))"
                    }
                    else {
                        totalTim = totalTim + 1
                        self?.forwadpauseTime = totalTim
                        cell.recordingCurrentTime.text = "0:\(totalTim)"
                    }
                }
            }
            
            else if forwadpauseTime != 0 && revsersepauseTime != 0 {
                print(self.forwadpauseTime)
                print(self.revsersepauseTime)
                
                var totaltim = revsersepauseTime
                reverselabelTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                    
                    if totaltim == 0 {
                        timer.invalidate()
                        cell.recordingTimeRemaining.text = "-0:00"
                        cell.recordingCurrentTime.text = "0:\(Manager.shared.GetRecordingTotalTime(indexpath: index))"
                    }
                    else {
                        totaltim = totaltim - 1
                        self?.revsersepauseTime = totaltim
                        print("Reverse Time: -\(totaltim)")
                        cell.recordingTimeRemaining.text = "-0:\(totaltim)"
                    }
                }
                
                var totaltime = forwadpauseTime
                forwadlabelTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                    
                    if totaltime == totalRecordingTime {
                        timer.invalidate()
                        cell.recordingPlayPauseButton.setBackgroundImage(UIImage(named: "Play") , for: .normal)
                        self?.isPlay = false
                        self!.progressValue = 0.0
                        self?.RemainProgess.invalidate()
                        cell.recordingProgress.progress = Float(self!.progressValue)
                        cell.recordingTimeRemaining.text = "-0:\(Manager.shared.GetRecordingTotalTime(indexpath: index))"
                    }
                    else {
                        totaltime = totaltime + 1
                        self?.forwadpauseTime = totaltime
                        print("Forwad Time: \(totaltime)")
                        cell.recordingCurrentTime.text = "0:\(totaltime)"
                    }
                }
            }
            self.isPlay = true
        }
        else {
            cell.recordingProgress.progress = Float(self.pauseProgress)
            cell.recordingTimeRemaining.text = "-0:\(self.revsersepauseTime)"
            cell.recordingCurrentTime.text = "0:\(self.forwadpauseTime)"
            
            RemainProgess.invalidate()
            forwadlabelTimer.invalidate()
            reverselabelTimer.invalidate()
            
            cell.recordingPlayPauseButton.setBackgroundImage(UIImage(named: "Play") , for: .normal)
            print("Recording is Paused")
            audioPlayer.pause()
            isPlay = false
        }
    }
}

extension RecordMemosViewController {
    
    // Mark:- Function to Get All Recordings from directory
    
    func GetRecordings() {
        AllRecordings = []
        
        let folderPath = Manager.shared.getDirectory()
        
        print("Folder Path: \(folderPath)")
        
        do {
            let audioPath = try FileManager.default.contentsOfDirectory(at: folderPath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            if audioPath.isEmpty {
                tableView.isHidden = true
                numberOfRecords = 0
                UserDefaults.standard.set(numberOfRecords, forKey: "RecordingNumber")
                print("No Recording in file.")
            }
            else {
                for audio in audioPath {
                    var myAudio = audio.absoluteString
                    
                    if myAudio.contains(".m4a") {
                        let findAudioName = myAudio.components(separatedBy: "/")
                        myAudio = findAudioName[findAudioName.count-1]
                        myAudio = myAudio.replacingOccurrences(of: "%20", with: " ")
                        myAudio = myAudio.replacingOccurrences(of: ".m4a", with: "")
                        AllRecordings.append(myAudio)
                        print(myAudio)
                        self.tableView.reloadData()
                    }
                }
            }
        }
        catch {
            print("Error Getting Recordings")
        }
    }
    
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
