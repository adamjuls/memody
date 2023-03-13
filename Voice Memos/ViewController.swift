//
//  ViewController.swift
//  Voice Memos
//
//  Created by Paula Luput on 3/5/23.
//  Copyright © 2023 Paula Luput. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, TableViewCellProtocols {
    
    //************************************************//
    // MARK:- Creating Outlets.
    //************************************************//
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var tapLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    
    //************************************************//
    // MARK: Creating properties.
    //************************************************//
    
    var refreshControl = UIRefreshControl()
    
    var AllTapes = [(String, String)]()
    
    var numberOfRecords:Int = 0
    
    //************************************************//
    // MARK:- View life Cycle
    //************************************************//
    
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
        
        if let Number: Int =  UserDefaults.standard.value(forKey: "RecordingNumber") as? Int {
            numberOfRecords = Number
            print(Number)
        }
        
        // handle interations of cells
        tableView.delegate = self
        // handle data of cells
        tableView.dataSource = self
        
        // refresh table of tapes
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        
        refreshControl.addTarget(self, action: #selector(PulltoRefresh(sender:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    //************************************************//
    // MARK:- Custom methods, actions and selectors.
    //************************************************//

    @objc func PulltoRefresh(sender: UIRefreshControl) {
        sender.endRefreshing()
        tableView.reloadData()
    }
    
    //************************************************//

    // MARK:- IBAction Methods

    @IBAction func recordButtonTapped(_ sender: UIButton) {
        numberOfRecords += 1
        let filename = Manager.shared.getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
        
        let vc = RecordMemosViewController()
        vc.filename = filename
        vc.numberOfRecords = numberOfRecords
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
    
    
}


extension ViewController : UITableViewDelegate,UITableViewDataSource {
    
    //************************************************//
    // MARK:- UITableview delegate and datesource
    //************************************************//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    //************************************************//
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if numberOfRecords == 0 {
            tableView.isHidden = true
            return 0
        }
        
        else {
            tableView.isHidden = false
            return AllTapes.count
        }
    }
    
    //************************************************//
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        
        cell.tapeName.text = AllTapes[indexPath.row].0
        cell.date.text = AllTapes[indexPath.row].1
        
        cell.delegate = self
        cell.deleteAudio.tag = indexPath.row
        
        return cell
    }
    
    //************************************************//
}

extension ViewController {
    
    // Mark:- Function to Get All Recordings from directory
    
    func GetRecordings() {
        AllTapes = []
        
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
                        // Create Date
                        let date = Date()
                        // Create Date Formatter
                        let dateFormatter = DateFormatter()
                        // Set Date Format
                        dateFormatter.dateFormat = "MM/dd/YY"
                        // Convert Date to String
                        let stringDate = dateFormatter.string(from: date)
                        // append audio with date
                        AllTapes.append((myAudio, stringDate))
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

}

//************************ FOR LATER: DELETE BUTTON ****************************//

//extension RecordMemosViewController : RecordingsTableViewCellProtocols {
//
//    // Mark:- Delete Recording Button Method
//
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
//}
