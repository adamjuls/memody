//
//  RecordingsTableViewCell.swift
//  Voice Memos
//
//  Created by Shahzaib on 3/5/22.
//  Copyright © 2022 Shahzaib. All rights reserved.
//

import UIKit
protocol RecordingsTableViewCellProtocols
{
    func PlayPauseTapped(cell: RecordingsTableViewCell)
    func DeleteButtonTapped(cell: RecordingsTableViewCell)
    func MIDIButtonTapped(cell: RecordingsTableViewCell, RecordingName: String)
}

class RecordingsTableViewCell: UITableViewCell {

    //************************************************//
    // MARK:- Creating Outlets.
    //************************************************//
    
    @IBOutlet weak var recordingName: UILabel!
    @IBOutlet weak var recordedCurrentTime: UILabel!
    @IBOutlet weak var recordingCurrentTime: UILabel!
    @IBOutlet weak var recordingTimeRemaining: UILabel!
    @IBOutlet weak var recordingPlayPauseButton: UIButton!
    @IBOutlet weak var recordingProgress: UIProgressView!
    @IBOutlet weak var deleteAudio: UIButton!
    @IBOutlet weak var convertMIDI: UIButton!
    //************************************************//
    
    var delegate:RecordingsTableViewCellProtocols?
    
    // MARK:- Play/Pause Button Tapped.
    
    @IBAction func PlayPauseButtonTapped(_ sender: UIButton) {
         delegate?.PlayPauseTapped(cell: self)
    }
    
    // MARK:- Delete Button Tapped.
    
    @IBAction func btnDeleteTapped(_ sender: UIButton) {
        delegate?.DeleteButtonTapped(cell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func btnMIDITapped(_ sender: UIButton) {
        delegate?.MIDIButtonTapped(cell: self, RecordingName: recordingName.text ?? "No Name")
    }
}
