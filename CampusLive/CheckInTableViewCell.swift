//
//  CheckInTableViewCell.swift
//  CampusLive
//
//  Created by Raghav Nyati on 4/7/17.
//  Copyright © 2017 Mihai Ruber. All rights reserved.
//

import UIKit

class CheckInTableViewCell: UITableViewCell {

    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
