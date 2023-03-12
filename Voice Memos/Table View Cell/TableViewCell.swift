//
//  TableViewCell.swift
//  Voice Memos
//
//  Created by Paula Luput on 3/5/22.
//  Copyright © 2023 Paula Luput. All rights reserved.
//

import UIKit
protocol TableViewCellProtocols
{

}

class TableViewCell: UITableViewCell {

    //************************************************//
    // MARK:- Creating Outlets.
    //************************************************//
    
    @IBOutlet weak var tapeName: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var deleteAudio: UIButton!
    
    //************************************************//
    
    var delegate:TableViewCellProtocols?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
